import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/app_providers.dart';
import './date_time_picker.dart';

// 用于创建project对话框工具类
class ProjectShowDialogUtil {
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showDialog<T>(context: context, builder: (_) => child);
  }

  static Future<void> showAddProjectDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String categoryId,
  }) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    // 用于存储选择的日期
    DateTime? startDate;
    DateTime? endDate;

    await showCustomDialog<void>(
      context: context,
      child: StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          scrollable: true,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            '新建项目',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'PingFang SC',
            ),
          ),
          content: SizedBox(
            width: 328.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题输入框
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      hintText: '输入项目标题',
                      labelText: '标题',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    autofocus: true,
                  ),
                  SizedBox(height: 16.h),

                  // 详情输入框
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      hintText: '输入项目详情',
                      labelText: '详情',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20.h),

                  Text(
                    '选择日期',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // 选择开始时间
                  DateTimePickerItem(
                    label: '选择开始日期和时间',
                    selectedDate: startDate,
                    onDateTimeSelected: (newDateTime) {
                      setState(() {
                        startDate = newDateTime;
                      });
                    },
                  ),

                  SizedBox(height: 12.h),

                  // 选择结束时间
                  DateTimePickerItem(
                    label: '选择结束日期和时间',
                    selectedDate: endDate,
                    onDateTimeSelected: (newDateTime) {
                      setState(() {
                        endDate = newDateTime;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
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
                if (titleCtrl.text.isNotEmpty &&
                    startDate != null &&
                    endDate != null) {
                  // 结束时间不能早于开始时间
                  if (endDate!.isBefore(startDate!)) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('结束时间不能早于开始时间'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // 提交数据
                  ref
                      .read(projectListProvider(categoryId).notifier)
                      .addProject(
                        titleCtrl.text,
                        descCtrl.text,
                        startDate!,
                        endDate!,
                      );
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(const SnackBar(content: Text('请填写完整信息并选择日期')));
                }
              },
              child: Text(
                '创建',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
