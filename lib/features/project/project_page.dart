import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_borad/route/app_routes.dart';
import '../../providers/app_providers.dart';
import '../../common_ui/project_item.dart';
import '../../common_utils/project_show_dialog_util.dart';

class ProjectPage extends ConsumerWidget {
  final String categoryId;
  final String categoryTitle;
  final bool isShared; // 标记是否为共享项目列表

  const ProjectPage({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    this.isShared = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 根据 isShared 决定使用哪个 provider
    final projectsAsyncValue = isShared
        ? ref.watch(sharedProjectsProvider)
        : ref.watch(projectListProvider(categoryId));

    final vm = isShared
        ? null
        : ref.read(projectListProvider(categoryId).notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar，包括返回按钮和标题
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          categoryTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      // 主体内容区域，显示项目列表或加载状态
      body: projectsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (projects) {
          // 如果列表为空，显示空状态
          if (projects.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                if (isShared) {
                  ref.invalidate(sharedProjectsProvider);
                } else {
                  ref.invalidate(projectListProvider(categoryId));
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: const Center(child: Text("暂无项目，点击下方按钮创建")),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 列表区域
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (isShared) {
                      ref.invalidate(sharedProjectsProvider);
                    } else {
                      ref.invalidate(projectListProvider(categoryId));
                    }
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    // 底部留白给 FAB，避免遮挡最后一个 item
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 100,
                    ),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      return ProjectItem(
                        project: projects[index],
                        showMemberCount: !isShared, // 共享项目不显示人数
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.task,
                            arguments: projects[index].id,
                          );
                          // 返回后刷新项目列表（成员人数可能改变）,根据 isShared 决定刷新哪个 provider
                          if (isShared) {
                            ref.invalidate(sharedProjectsProvider);
                          } else {
                            ref.invalidate(projectListProvider(categoryId));
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // 共享项目列表不显示添加按钮（无法在别人的项目里创建新项目）
      floatingActionButton: isShared
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.white,
              shape: const CircleBorder(
                side: BorderSide(color: Colors.black, width: 2),
              ),
              elevation: 0,
              child: const Icon(Icons.add, color: Colors.black, size: 30),
              onPressed: () {
                ProjectShowDialogUtil.showAddProjectDialog(
                  context: context,
                  ref: ref,
                  categoryId: categoryId,
                );
              },
            ),
    );
  }
}
