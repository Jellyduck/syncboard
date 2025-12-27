import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/app_providers.dart';

// 创建category对话框工具类
class ShowDialogUtil {
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showDialog<T>(context: context, builder: (_) => child);
  }

  static Future<void> showAddCategoryDialog({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final textController = TextEditingController();
    const iconOptions = <String, IconData>{
      'work': Icons.work_outline,
      'person': Icons.person_outline,
      'meeting': Icons.people_outline,
      'events': Icons.calendar_today_outlined,
      'private': Icons.lock_outline,
      'folder': Icons.folder_open,
    };
    String selectedIcon = 'work';
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
            '创建新的分类',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'PingFang SC',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: '输入分类名称',
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
                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    '选择图标',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Center(
                  child: Wrap(
                    spacing: 12.r,
                    runSpacing: 12.r,
                    children: iconOptions.entries.map((entry) {
                      final isSelected = selectedIcon == entry.key;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIcon = entry.key),
                        child: Container(
                          width: 64.r,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                entry.value,
                                size: 24.r,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                entry.key[0].toUpperCase() +
                                    entry.key.substring(1),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontFamily: 'PingFang SC',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
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
                if (textController.text.isNotEmpty) {
                  ref
                      .read(categoryListProvider.notifier)
                      .addCategory(textController.text, iconName: selectedIcon);
                  Navigator.of(dialogContext).pop();
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
