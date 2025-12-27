import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class TaskRepository {
  final SupabaseClient _supabase;
  TaskRepository(this._supabase);

  // 获取特定 Project 的任务流（实时更新）
  Stream<List<Task>> getTasksStream(String projectId) {
    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('order_index', ascending: true)
        .map((data) => data.map((json) => Task.fromJson(json)).toList());
  }

  // 添加任务
  Future<void> addTask(String projectId, String title) async {
    await _supabase.from('tasks').insert({
      'project_id': projectId,
      'title': title,
      'is_completed': false,
      'order_index': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
  }

  // 更新任务状态
  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    await _supabase
        .from('tasks')
        .update({'is_completed': isCompleted})
        .eq('id', taskId);
  }

  // 删除任务
  Future<void> deleteTask(String taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }
}
