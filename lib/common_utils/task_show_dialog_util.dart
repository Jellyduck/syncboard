import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../features/task/task_vm.dart';

// 创建task对话框工具类
class TaskShowDialogUtil {
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showDialog<T>(context: context, builder: (_) => child);
  }

  static Future<void> showAddTaskDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String projectId,
  }) async {
    final textController = TextEditingController();
    await showCustomDialog<void>(
      context: context,
      child: AlertDialog(
        scrollable: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          '新建任务',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'PingFang SC',
          ),
        ),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: '请输入任务内容',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: TextStyle(color: Colors.grey, fontSize: 16.sp),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              if (textController.text.isNotEmpty) {
                ref
                    .read(taskViewModelProvider(projectId).notifier)
                    .addTask(textController.text);
                Navigator.of(context).pop();
              }
            },
            child: Text(
              '添加',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }
}
