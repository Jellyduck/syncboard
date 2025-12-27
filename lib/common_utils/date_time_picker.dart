import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// 日期时间选择项组件
// 日期时间选择输入框 + 交互逻辑(先选日期，后选时间)
class DateTimePickerItem extends StatelessWidget {
  final String label; // 未选择时显示的提示文字
  final DateTime? selectedDate; // 当前选中的时间
  final Function(DateTime) onDateTimeSelected; // 选中后的回调

  const DateTimePickerItem({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 点击触发之后的流程
      onTap: () async {
        // 日期选择器
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          locale: const Locale('zh', 'CN'),
          builder: (context, child) {
            // 自定义日期弹窗的主题颜色（黑白风格）
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.black, // 选中颜色
                  onSurface: Colors.black, // 文本颜色
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          // 调用时间滚轮
          if (context.mounted) {
            final pickedTime = await _showScrollTimePicker(
              selectedDate != null
                  ? TimeOfDay.fromDateTime(selectedDate!)
                  : TimeOfDay.now(),
              context,
            );

            // 合并日期和时间并返回
            if (pickedTime != null) {
              final finalDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              onDateTimeSelected(finalDateTime);
            }
          }
        }
      },
      // 显示出来的UI，带边框的输入框
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? label
                  : DateFormat('yyyy-MM-dd HH:mm').format(selectedDate!),
              style: TextStyle(
                fontSize: 14.sp,
                color: selectedDate == null ? Colors.grey : Colors.black,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  // 私有方法，用于显示底部弹出的时间滚轮
  Future<TimeOfDay?> _showScrollTimePicker(
    TimeOfDay initialTime,
    BuildContext context,
  ) {
    Duration selectedDuration = Duration(
      hours: initialTime.hour,
      minutes: initialTime.minute,
    );

    return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Container(
            width: 375.w, // 宽度占满屏幕
            padding: EdgeInsets.only(top: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            height: 320.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部操作栏，包括取消/标题/确定
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Text(
                        '选择时间',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(
                            TimeOfDay(
                              hour: selectedDuration.inHours % 24,
                              minute: selectedDuration.inMinutes % 60,
                            ),
                          );
                        },
                        child: Text(
                          '确定',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 时间滚轮主体
                Expanded(
                  // 强制浅色主题，确保滚轮文字为黑色
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      brightness: Brightness.light,
                      textTheme: CupertinoTextThemeData(
                        pickerTextStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hm,
                      initialTimerDuration: selectedDuration,
                      minuteInterval: 1,
                      onTimerDurationChanged: (duration) {
                        selectedDuration = duration;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
