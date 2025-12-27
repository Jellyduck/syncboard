import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../providers/app_providers.dart';

part 'member_vm.g.dart';

@Riverpod(keepAlive: true)
class MemberManageViewModel extends _$MemberManageViewModel {
  @override
  FutureOr<void> build() {
    // 不需要初始状态
  }

  // 添加成员
  Future<void> addMember(String projectId, String userId) async {
    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        await ref
            .read(memberRepositoryProvider)
            .addMember(projectId: projectId, userId: userId);
        // 成功后，刷新该项目的成员列表
        if (ref.mounted) {
          ref.invalidate(membersProvider(projectId));
          ref.invalidate(projectDetailProvider(projectId));
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 移除成员
  Future<void> removeMember(String projectId, String userId) async {
    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        await ref
            .read(memberRepositoryProvider)
            .removeMember(projectId: projectId, userId: userId);
        if (ref.mounted) {
          ref.invalidate(membersProvider(projectId));
          ref.invalidate(projectDetailProvider(projectId));
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// 搜索用户
@riverpod
Future<List<Map<String, dynamic>>> userSearch(Ref ref, String query) async {
  await Future.delayed(const Duration(milliseconds: 500));
  final result = await ref.read(memberRepositoryProvider).searchUsers(query);
  return result;
}
