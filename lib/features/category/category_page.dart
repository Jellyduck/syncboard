import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common_ui/add_card.dart';
import '../../common_ui/category_card.dart';
import '../../common_utils/category_show_dialog_util.dart';
import '../../providers/app_providers.dart';
import '../../route/app_routes.dart';
import '../../models/project_model.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  bool _isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _enterDeleteMode() {
    // 进入删除模式，开始抖动动画
    if (_isDeleteMode) return;
    setState(() => _isDeleteMode = true);
    _shakeController.repeat();
  }

  void _exitDeleteMode() {
    // 退出删除模式，停止动画
    if (!_isDeleteMode) return;
    setState(() => _isDeleteMode = false);
    _shakeController.stop();
    _shakeController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(categoryListProvider);
    final sharedProjectsState = ref.watch(sharedProjectsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // 标题
        title: Text(
          'SyncBoard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 25.sp,
          ),
        ),
        // 退出登录按钮
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.black, size: 28.r),
          onPressed: () {
            ref.read(authVmProvider.notifier).signOut();
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          },
        ),
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (categories) {
          // 检查是否有共享项目
          final sharedProjects = sharedProjectsState.maybeWhen(
            data: (projects) => projects,
            orElse: () => <ProjectModel>[],
          );
          final hasSharedProjects = sharedProjects.isNotEmpty;

          return AnimatedBuilder(
            animation: _shakeController,
            builder: (context, _) {
              final shakeAngle = _isDeleteMode
                  ? math.sin(_shakeController.value * 2 * math.pi) *
                        0.04 // 计算卡片抖动角度
                  : 0.0;

              // 使用 GestureDetector 包裹整个区域，点击空白处退出删除模式
              return GestureDetector(
                onTap: () {
                  if (_isDeleteMode) {
                    _exitDeleteMode();
                  }
                },
                // 确保空白区域也能响应点击
                behavior: HitTestBehavior.translucent,
                child: RefreshIndicator(
                  onRefresh: () async {
                    // 刷新分类列表和共享项目
                    ref.invalidate(sharedProjectsProvider);
                    await ref
                        .read(categoryListProvider.notifier)
                        .loadCategories();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14.r,
                        mainAxisSpacing: 14.r,
                        childAspectRatio: 1.0,
                      ),
                      // 总数 = 共享卡片(0或1) + 分类数 + 添加按钮(1)
                      itemCount:
                          (hasSharedProjects ? 1 : 0) + categories.length + 1,
                      itemBuilder: (context, index) {
                        // 第一个位置：分享给我的卡片（如果有共享项目）
                        if (index == 0 && hasSharedProjects) {
                          return CategoryCard(
                            title: '分享给我',
                            projectCount: sharedProjects.length,
                            iconName: 'folder_shared', // 特殊图标
                            onTap: () async {
                              await Navigator.of(context).pushNamed(
                                AppRoutes.project,
                                arguments: {
                                  'categoryId': 'shared',
                                  'categoryTitle': '分享给我',
                                  'isShared': true,
                                },
                              );
                              // 返回后刷新
                              ref.invalidate(sharedProjectsProvider);
                              await ref
                                  .read(categoryListProvider.notifier)
                                  .loadCategories();
                            },
                            isDeleteMode: false, // 共享卡片不可删除
                            shakeAngle: 0,
                            onDeleteTap: null,
                            onDeleteModeTap: null,
                            onLongPress: null, // 不响应长按
                          );
                        }

                        // 调整后续索引
                        final categoryIndex = hasSharedProjects
                            ? index - 1
                            : index;

                        // 最后一个位置：添加按钮
                        if (categoryIndex == categories.length) {
                          return AddCard(
                            onTap: () {
                              if (_isDeleteMode) {
                                _exitDeleteMode();
                                return;
                              }
                              ShowDialogUtil.showAddCategoryDialog(
                                context: context,
                                ref: ref,
                              );
                            },
                          );
                        }

                        // 普通分类卡片
                        final category = categories[categoryIndex];
                        return CategoryCard(
                          title: category.title,
                          projectCount: category.taskCount,
                          iconName: category.iconName,
                          onTap: () async {
                            await Navigator.of(context).pushNamed(
                              AppRoutes.project,
                              arguments: {
                                'categoryId': category.id,
                                'categoryTitle': category.title,
                              },
                            );
                            // 返回后刷新列表数据
                            await ref
                                .read(categoryListProvider.notifier)
                                .loadCategories();
                          },
                          isDeleteMode: _isDeleteMode,
                          shakeAngle: shakeAngle,
                          onDeleteTap: () => ref
                              .read(categoryListProvider.notifier)
                              .deleteCategory(category.id),
                          onDeleteModeTap: _exitDeleteMode,
                          onLongPress: _isDeleteMode
                              ? null
                              : () => _enterDeleteMode(),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
