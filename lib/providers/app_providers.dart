import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/auth_vm.dart';
import '../features/avatar/avatar_vm.dart';
import '../repositories/auth_repository.dart';
import '../repositories/avatar_repository.dart';
import '../repositories/category_repository.dart';
import '../features/category/category_vm.dart';
import '../models/category_model.dart';
import '../repositories/project_repository.dart';
import '../features/project/project_vm.dart';
import '../models/project_model.dart';
import '../repositories/task_repository.dart';
import '../models/member_model.dart';
import '../repositories/member_repository.dart';
import '../repositories/chat_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

//----------登录注册相关providers----------

// 监听登录登出状态，直接返回完整的 AuthState，这样可以拿到 User 和事件类型
final authStateProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange.map((data) => data.session?.user);
});

// 当前用户 ID Provider
final currentUserIdProvider = Provider<String?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser?.id;
});

// 当前用户 Provider
final currentUserProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser;
});

// 提供调用登录，注册，注销方法的provider，执行认证操作
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});

// authVmProvider 用于提供给UI层调用登录，注册方法
final authVmProvider = StateNotifierProvider<AuthViewModel, AsyncValue<void>>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository);
});

//----------头像上传相关 providers----------

// 头像 Repository，用于上传文件和更新 profiles.avatar_url
final avatarRepositoryProvider = Provider<AvatarRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AvatarRepository(client);
});

// 头像 ViewModel，用于在 UI 中调用 updateAvatar
final profileVmProvider =
    StateNotifierProvider<AvatarViewModel, AsyncValue<void>>((ref) {
      final repository = ref.watch(avatarRepositoryProvider);
      return AvatarViewModel(repository);
    });

//----------分类相关 providers----------
// Repository Provider
final categoryRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CategoryRepository(client);
});

// ViewModel Provider 使用 StateNotifierProvider 来管理一个异步列表状态
final categoryListProvider =
    StateNotifierProvider<CategoryViewModel, AsyncValue<List<CategoryModel>>>((
      ref,
    ) {
      final repository = ref.watch(categoryRepositoryProvider);
      return CategoryViewModel(repository);
    });

//----------project相关 providers----------

final projectRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProjectRepository(client);
});

final projectListProvider =
    StateNotifierProvider.family<
      ProjectViewModel,
      AsyncValue<List<ProjectModel>>,
      String
    >((ref, categoryId) {
      final repository = ref.watch(projectRepositoryProvider);
      return ProjectViewModel(repository, categoryId);
    });

// 获取单个项目详情的 provider
final projectDetailProvider = FutureProvider.family<ProjectModel, String>((
  ref,
  projectId,
) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.fetchProjectById(projectId);
});

// 获取分享给我的项目列表
final sharedProjectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.fetchSharedProjects();
});

//----------Member 相关 providers----------

final memberRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MemberRepository(client);
});

// 获取项目成员列表
final membersProvider = FutureProvider.family<List<ProjectMemberModel>, String>(
  (ref, projectId) async {
    final repository = ref.watch(memberRepositoryProvider);
    final members = await repository.fetchProjectMembers(projectId);
    return members;
  },
);

// 在线用户 Presence Provider（无需数据库字段）
final onlineUsersProvider = StreamProvider.family<List<String>, String>((
  ref,
  projectId,
) {
  final supabase = ref.watch(supabaseClientProvider);
  final myUserId = supabase.auth.currentUser?.id;
  final channel = supabase.channel('room_$projectId');

  final controller = StreamController<List<String>>.broadcast();

  void emitCurrentState() {
    final presences = channel.presenceState();
    final userIds = <String>{};

    // presenceState() 返回 List<SinglePresenceState>
    // 每个 SinglePresenceState 有 key 和 presences (List<Presence>)
    for (final state in presences) {
      for (final presence in state.presences) {
        // Presence 对象有 payload 属性
        final payload = presence.payload;
        if (payload['user_id'] is String) {
          userIds.add(payload['user_id'] as String);
        }
      }
    }
    controller.add(userIds.toList());
  }

  channel.onPresenceSync((_) {
    emitCurrentState();
  });

  channel.subscribe((status, error) async {
    if (status == RealtimeSubscribeStatus.subscribed && myUserId != null) {
      await channel.track({
        'user_id': myUserId,
        'online_at': DateTime.now().toIso8601String(),
      });
      emitCurrentState();
    }
  });

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

//----------Task 相关 providers----------

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TaskRepository(client);
});

// ------------------chat message相关--------------
final chatRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ChatRepository(client);
});
