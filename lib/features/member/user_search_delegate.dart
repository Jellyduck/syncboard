import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'member_vm.dart';

// 用户搜索
class UserSearchDelegate extends SearchDelegate {
  final WidgetRef ref;
  final String projectId;

  UserSearchDelegate(this.ref, this.projectId);

  @override
  String get searchFieldLabel => '搜索用户名...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.trim().isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(child: Text('请输入用户名进行搜索')),
      );
    }

    final searchAsync = ref.watch(userSearchProvider(query));

    return Container(
      color: Colors.white,
      child: searchAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('未找到用户'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['avatar_url'] != null
                        ? NetworkImage(user['avatar_url'])
                        : null,
                    child: user['avatar_url'] == null
                        ? Text((user['username'] as String)[0].toUpperCase())
                        : null,
                  ),
                  title: Text(user['username'] ?? 'Unknown'),
                  trailing: const Icon(Icons.person_add_alt_1),
                  onTap: () async {
                    final notifier = ref.read(
                      memberManageViewModelProvider.notifier,
                    );
                    final username = user['username'] ?? 'Unknown';

                    try {
                      await notifier.addMember(projectId, user['id']);

                      if (context.mounted) {
                        close(context, null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已添加 $username')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        final errorMsg = e.toString();
                        if (errorMsg.contains('已经是项目成员')) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text(
                                '无法添加',
                                style: TextStyle(fontSize: 18),
                              ),
                              content: Text(
                                '$username 已经是项目成员',
                                style: const TextStyle(fontSize: 14),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text(
                                    '确定',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('添加失败: $e')));
                        }
                      }
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('搜索出错: $err')),
      ),
    );
  }
}
