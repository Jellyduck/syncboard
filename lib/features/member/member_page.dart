import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import 'member_vm.dart';
import 'user_search_delegate.dart';

class ManageMembersPage extends ConsumerWidget {
  final String projectId;
  // 用于判断是否显示删除按钮
  final String currentUserId;
  final bool isOwner;

  const ManageMembersPage({
    super.key,
    required this.projectId,
    required this.currentUserId,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider(projectId));
    final onlineUsersAsync = ref.watch(onlineUsersProvider(projectId));
    final manageState = ref.watch(memberManageViewModelProvider);
    final isProcessing = manageState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,

      // 顶部标题和返回按钮
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "管理成员",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),

      // 成员列表
      body: Column(
        children: [
          if (isProcessing) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: membersAsync.when(
              data: (members) {
                final onlineUsers = onlineUsersAsync.asData?.value ?? [];
                return RefreshIndicator(
                  onRefresh: () async {
                    // 刷新成员列表
                    ref.invalidate(membersProvider(projectId));
                    // 刷新在线状态
                    ref.invalidate(onlineUsersProvider(projectId));
                    // 等待数据重新加载
                    await ref.read(membersProvider(projectId).future);
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  // 显示成员列表
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isOnline = onlineUsers.contains(member.userId);
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                backgroundImage: member.avatarUrl != null
                                    ? NetworkImage(member.avatarUrl!)
                                    : null,
                                child: member.avatarUrl == null
                                    ? Text(
                                        (member.username ?? '?')[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      )
                                    : null,
                              ),
                              // 如果成员在线，显示绿色在线状态点
                              if (isOnline)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            member.username ?? "未知用户",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          // 仅当当前用户是所有者且成员不是自己时，显示删除按钮
                          trailing: isOwner && member.userId != currentUserId
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: isProcessing
                                      ? null
                                      : () async {
                                          final membervm = ref.read(
                                            memberManageViewModelProvider
                                                .notifier,
                                          );
                                          final memberName =
                                              member.username ?? "用户";

                                          try {
                                            await membervm.removeMember(
                                              projectId,
                                              member.userId,
                                            );

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '已移除 $memberName',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text('移除失败: $e'),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                )
                              : const Tooltip(
                                  message: "不可删除自己或非所有者",
                                  child: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
      // 仅当当前用户是所有者时，显示添加成员按钮
      floatingActionButton: isOwner
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              shape: const CircleBorder(
                side: BorderSide(color: Colors.black, width: 2),
              ),
              elevation: 0,
              child: const Icon(Icons.person_add, color: Colors.black),
              onPressed: () {
                if (isProcessing) return;
                // 弹窗显示搜索用户的 UI
                showSearch(
                  context: context,
                  delegate: UserSearchDelegate(ref, projectId),
                );
              },
            )
          : null,
    );
  }
}
