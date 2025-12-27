import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/task_model.dart';
import '../../providers/app_providers.dart';

part 'task_vm.g.dart';

@riverpod
class TaskViewModel extends _$TaskViewModel {
  @override
  Stream<List<Task>> build(String projectId) {
    final repository = ref.watch(taskRepositoryProvider);
    return repository.getTasksStream(projectId);
  }

  String? currentUserId() {
    final supabaseClient = ref.read(supabaseClientProvider);
    return supabaseClient.auth.currentUser?.id;
  }

  bool isOwner(String ownerId) {
    final currentId = currentUserId();
    return currentId != null && currentId == ownerId;
  }

  Future<void> addTask(String title) async {
    await ref.read(taskRepositoryProvider).addTask(projectId, title);
  }

  Future<void> toggleTask(String taskId, bool currentVal) async {
    await ref
        .read(taskRepositoryProvider)
        .updateTaskStatus(taskId, !currentVal);
  }

  Future<void> deleteTask(String taskId) async {
    await ref.read(taskRepositoryProvider).deleteTask(taskId);
  }
}
