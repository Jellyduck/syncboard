import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/project_model.dart';
import '../providers/app_providers.dart';

/// 项目列表项组件
class ProjectItem extends ConsumerWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final bool showMemberCount;

  const ProjectItem({
    super.key,
    required this.project,
    this.onTap,
    this.showMemberCount = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseClient = ref.watch(supabaseClientProvider);
    final currentUserId = supabaseClient.auth.currentUser?.id;
    final isOwner = currentUserId == project.ownerId;

    String formatDateTime(DateTime? dt) {
      if (dt == null) return "--";
      return DateFormat('MM-dd HH:mm').format(dt);
    }

    final timeString =
        "${formatDateTime(project.startAt)} - ${formatDateTime(project.endAt)}";

    // 状态逻辑
    String getProjectStatus() {
      final now = DateTime.now();
      if (project.startAt == null || project.endAt == null) return "未设置";
      if (now.isBefore(project.startAt!)) return "未开始";
      if (now.isAfter(project.endAt!)) return "已结束";
      return "进行中";
    }

    // 样式配置
    (Color, Color, Color) getStatusColors(String status) {
      switch (status) {
        case "进行中":
          return (Colors.black, Colors.white, Colors.black);
        case "未开始":
          return (Colors.white, Colors.black, Colors.black);
        case "已结束":
        default:
          return (Colors.grey[200]!, Colors.grey[600]!, Colors.transparent);
      }
    }

    final statusText = getProjectStatus();
    final (statusBg, statusFg, statusBorder) = getStatusColors(statusText);

    return Dismissible(
      key: Key(project.id),
      direction: isOwner ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        color: const Color(0xFFE53935),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      // 滑动删除，弹出确认对话框
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('删除项目？', style: TextStyle(fontSize: 18)),
            content: const Text(
              '确定要删除吗？此操作无法撤销。',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('删除', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        try {
          await ref
              .read(projectListProvider(project.categoryId).notifier)
              .deleteProject(project.id);
        } catch (e) {
          // Error handling
        }
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 20, right: 20, top: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和状态
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 状态标签
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      border: Border.all(color: statusBorder, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusFg,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // 项目描述
              if (project.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    project.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const SizedBox(height: 8),

              Row(
                // 时间，成员数，身份标签
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeString,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),
                  if (showMemberCount) ...[
                    const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "${project.memberCount}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isOwner ? Colors.black : Colors.grey[400]!,
                        width: 0.8,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isOwner ? "创建者" : "参与者",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isOwner ? Colors.black : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Divider(height: 1, thickness: 1, color: Colors.grey[100]),
            ],
          ),
        ),
      ),
    );
  }
}
