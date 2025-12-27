import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/task/task_vm.dart';
import '../models/task_model.dart';

// 任务列表中的单个任务项 Widget
class TaskTile extends ConsumerWidget {
  final Task task;
  final String projectId;

  const TaskTile({super.key, required this.task, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: const Color(0xFFE53935),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        // 先删除数据，等待 stream 更新后自动移除 widget
        // 返回 false 阻止 Dismissible 自己的移除动画，避免状态不同步
        ref.read(taskViewModelProvider(projectId).notifier).deleteTask(task.id);
        return false;
      },
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (value) {
            ref
                .read(taskViewModelProvider(projectId).notifier)
                .toggleTask(task.id, task.isCompleted);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }
}
