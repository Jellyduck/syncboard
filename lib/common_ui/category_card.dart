import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final int projectCount;
  final String iconName;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onDeleteModeTap;
  final bool isDeleteMode;
  final double shakeAngle;

  const CategoryCard({
    super.key,
    required this.title,
    required this.projectCount,
    required this.iconName,
    this.onTap,
    this.onLongPress,
    this.onDeleteTap,
    this.onDeleteModeTap,
    this.isDeleteMode = false,
    this.shakeAngle = 0,
  });

  IconData getIcon(String name) {
    switch (name) {
      case 'work':
        return Icons.work_outline;
      case 'person':
        return Icons.person_outline;
      case 'meeting':
        return Icons.people_outline;
      case 'events':
        return Icons.calendar_today_outlined;
      case 'private':
        return Icons.lock_outline;
      default:
        return Icons.folder_open;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isDeleteMode) {
          onDeleteModeTap?.call(); // 退出删除模式，仅当点击删除标志才会删除，点击卡片本身会退出删除模式
        } else {
          onTap?.call();
        }
      },
      onLongPress: onLongPress,
      child: Transform.rotate(
        angle: shakeAngle,
        child: Container(
          margin: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.grey.shade200, width: 1.r),
          ),
          child: Stack(
            children: [
              // 删除按钮
              if (isDeleteMode)
                Positioned(
                  top: 0,
                  left: 0,
                  child: GestureDetector(
                    onTap: onDeleteTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r), // 跟随卡片圆角
                          bottomRight: Radius.circular(20.r), // 稍微大一点的圆角
                        ),
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Colors.grey[700],
                        size: 26.r,
                      ),
                    ),
                  ),
                ),

              // 右上角的业务图标
              Positioned(
                top: 12.r,
                right: 12.r,
                child: Icon(
                  getIcon(iconName),
                  size: 26.r,
                  color: Colors.black87,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '$projectCount 个项目',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
