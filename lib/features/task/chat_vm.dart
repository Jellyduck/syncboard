import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_message_model.dart';
import '../../providers/app_providers.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

part 'chat_vm.g.dart';

// 聊天消息状态管理（包含分页）
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  Future<List<ChatMessageModel>> build(String projectId) async {
    // 初始加载最新30条消息
    final messages = await ref
        .read(chatRepositoryProvider)
        .getLatestMessages(projectId);

    // 启动实时监听
    _startRealtimeListener(projectId);

    return messages;
  }

  // 启动实时监听
  void _startRealtimeListener(String projectId) {
    final subscription = ref
        .read(chatRepositoryProvider)
        .watchMessages(projectId)
        .listen((newMessage) {
          addNewMessage(newMessage);
        }, onError: (error) {});

    // 当 Provider 被销毁时取消订阅
    ref.onDispose(() {
      subscription.cancel();
    });
  }

  // 加载更多（往前翻）
  Future<void> loadMore() async {
    final currentMessages = state.value;
    if (currentMessages == null || currentMessages.isEmpty) return;

    // 获取最早的消息时间
    final oldestTime = currentMessages.first.createdAt;

    try {
      final olderMessages = await ref
          .read(chatRepositoryProvider)
          .getOlderMessages(projectId, beforeTime: oldestTime);

      if (olderMessages.isNotEmpty) {
        // 将旧消息添加到前面
        state = AsyncData([...olderMessages, ...currentMessages]);
      }
    } catch (e) {
      // 加载失败，保持当前状态
      print('加载更多消息失败: $e');
    }
  }

  // 添加新消息（用于实时更新）
  void addNewMessage(ChatMessageModel message) {
    final currentMessages = state.value ?? [];
    
    // 去重检查
    if (currentMessages.any((m) => m.id == message.id)) {
      return;
    }
    
    // 只接受比当前最新消息更新的消息，避免旧消息被添加到末尾
    if (currentMessages.isNotEmpty) {
      final latestTime = currentMessages.last.createdAt;
      if (message.createdAt.isBefore(latestTime) || 
          message.createdAt.isAtSameMomentAs(latestTime)) {
        // 如果是旧消息或同一时间的消息，忽略（这些消息应该通过分页加载）
        return;
      }
    }
    
    // 添加新消息到末尾
    state = AsyncData([...currentMessages, message]);
  }
}

@riverpod
class ChatController extends _$ChatController {
  final ImagePicker _picker = ImagePicker();

  @override
  FutureOr<void> build() {
    // 初始状态
  }

  Future<void> sendTextMessage(
    String projectId,
    String content,
    String username,
  ) async {
    final link = ref.keepAlive();

    // 提前读取 Repository (防止 ref 失效)
    final repository = ref.read(chatRepositoryProvider);

    state = const AsyncLoading();

    try {
      await _sendMessageInternal(projectId, content, username, 'text');

      state = const AsyncData(null);

      // 实时监听会自动更新消息列表，不需要手动刷新
    } catch (e) {
      // 捕获错误
      state = AsyncError(e, StackTrace.current);
    } finally {
      // 如果此时页面已经关了，Provider 会在这里被销毁
      link.close();
    }
  }

  // 发送图片消息
  Future<void> sendImageMessage(String projectId, String username) async {
    // keepAlive 应在任何异步操作前调用，避免 ref 被提前销毁
    final link = ref.keepAlive();
    state = const AsyncLoading();

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) {
        state = const AsyncData(null);
        return;
      }

      final repository = ref.read(chatRepositoryProvider);
      final userId = ref.read(currentUserIdProvider) ?? '';

      final imageUrl = await repository.uploadChatImage(
        File(image.path),
        userId,
      );

      await _sendMessageInternal(projectId, imageUrl, username, 'image');
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      link.close();
    }
  }

  // 统一的内部发送逻辑
  Future<void> _sendMessageInternal(
    String projectId,
    String content,
    String username,
    String messageType,
  ) async {
    final link = ref.keepAlive();

    final repository = ref.read(chatRepositoryProvider);
    // 如果当前不是 Loading (比如发送文本时)，设置为 Loading
    if (state is! AsyncLoading) {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(() async {
      await repository.sendMessage(
        projectId: projectId,
        content: content,
        username: username,
        messageType: messageType, // 传入消息类型
      );
    });
    link.close();
  }
}
