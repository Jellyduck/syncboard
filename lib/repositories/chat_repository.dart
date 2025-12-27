import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message_model.dart';
import 'dart:io';

class ChatRepository {
  final SupabaseClient _supabase;
  ChatRepository(this._supabase);

  // 获取最新的 limit 条消息（用于初始化）
  Future<List<ChatMessageModel>> getLatestMessages(
    String projectId, {
    int limit = 30,
  }) async {
    final response = await _supabase
        .from('chat_messages')
        .select()
        .eq('project_id', projectId)
        .order('created_at', ascending: false)
        .limit(limit);

    final List<ChatMessageModel> messages = (response as List)
        .map((e) => ChatMessageModel.fromJson(e))
        .toList();

    // 反转列表，最早的消息在前
    return messages.reversed.toList();
  }

  // 实时监听消息变化
  Stream<ChatMessageModel> watchMessages(String projectId) {
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => ChatMessageModel.fromJson(json)))
        .expand((messages) => messages);
  }

  // 加载更早的消息（分页）一次加载30条
  Future<List<ChatMessageModel>> getOlderMessages(
    String projectId, {
    required DateTime beforeTime,
    int limit = 30,
  }) async {
    final response = await _supabase
        .from('chat_messages')
        .select()
        .eq('project_id', projectId)
        .lt('created_at', beforeTime.toIso8601String())
        .order('created_at', ascending: false)
        .limit(limit);

    final List<ChatMessageModel> messages = (response as List)
        .map((e) => ChatMessageModel.fromJson(e))
        .toList();

    // 反转列表
    return messages.reversed.toList();
  }

  // 发送消息
  Future<void> sendMessage({
    required String projectId,
    required String content,
    required String username,
    String messageType = 'text',
  }) async {
    final currentUser = _supabase.auth.currentUser;

    final uid = currentUser?.id;

    final data = {
      'project_id': projectId,
      'user_id': uid,
      'content': content,
      'username': username,
      'message_type': messageType,
    };

    try {
      final response = await _supabase.from('chat_messages').insert(data);
    } catch (e) {
      print('发送消息失败: $e');
      rethrow;
    }
  }

  // 上传图片到 Storage
  Future<String> uploadChatImage(File imageFile, String userId) async {
    try {
      // 生成唯一的文件名：用户ID_时间戳.扩展名
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$fileName'; // 按用户文件夹分类存储

      // 上传到 'chat_images' bucket
      await _supabase.storage
          .from('chat_images')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // 获取公开访问的 URL
      final imageUrl = _supabase.storage
          .from('chat_images')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('图片上传失败: $e');
    }
  }
}
