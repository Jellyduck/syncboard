import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common_ui/member_avatars.dart';
import '../../common_ui/task_tile.dart';
import '../../common_utils/date_range_formatter.dart';
import '../../common_utils/task_show_dialog_util.dart';
import '../../providers/app_providers.dart';
import '../../route/app_routes.dart';
import 'task_vm.dart';
import './chat_vm.dart';

class TaskPage extends ConsumerStatefulWidget {
  final String projectId;

  const TaskPage({super.key, required this.projectId});

  @override
  ConsumerState<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  static const double _chatInputHeight = 70;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _chatScrollController.addListener(_onScroll);

    // 延迟滚动到底部，确保消息加载完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(jump: true);
    });
  }

  // 滚动到底部，发完消息后调用
  void _scrollToBottom({bool jump = false}) {
    if (_chatScrollController.hasClients) {
      final target = _chatScrollController.position.maxScrollExtent;
      if (jump) {
        _chatScrollController.jumpTo(target);
      } else {
        _chatScrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  // 检查用户是否在底部（容差 100 像素）
  bool _isAtBottom() {
    if (!_chatScrollController.hasClients) return false;
    final maxExtent = _chatScrollController.position.maxScrollExtent;
    final currentOffset = _chatScrollController.position.pixels;
    return (maxExtent - currentOffset) <= 100;
  }

  @override
  void dispose() {
    _chatScrollController.removeListener(_onScroll);
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  // 监听滚动，当滚动到顶部时加载更多
  void _onScroll() {
    if (_isLoadingMore) return;

    final threshold = _chatScrollController.position.minScrollExtent + 20;
    if (_chatScrollController.position.pixels <= threshold) {
      _loadMoreMessages();
    }
  }

  // 加载更多消息，同时在保持当前滚动位置
  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;

    // 记录当前滚动位置和最大滚动范围
    final previousOffset = _chatScrollController.hasClients
        ? _chatScrollController.position.pixels
        : null;
    final previousMaxExtent = _chatScrollController.hasClients
        ? _chatScrollController.position.maxScrollExtent
        : null;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await ref
          .read(chatMessagesProvider(widget.projectId).notifier)
          .loadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }

      // 计算新的滚动位置以保持视图不变
      if (_chatScrollController.hasClients &&
          previousOffset != null &&
          previousMaxExtent != null) {
        final currentMaxExtent = _chatScrollController.position.maxScrollExtent;
        final delta = currentMaxExtent - previousMaxExtent;
        final targetOffset = (previousOffset + delta).clamp(
          0.0,
          currentMaxExtent,
        );
        _chatScrollController.jumpTo(targetOffset);
      }
    }
  }

  void _handleSendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    // 从 Provider 获取当前用户 ID
    final myUserId = ref.read(currentUserIdProvider);

    // 从成员列表中获取当前用户的 username
    final membersAsyncValue = ref.read(membersProvider(widget.projectId));

    String username = "我"; // 默认值
    membersAsyncValue.whenData((members) {
      final currentMember = members.firstWhere(
        (member) => member.userId == myUserId,
        orElse: () => members.first,
      );
      username = currentMember.username ?? "我";
    });

    _chatController.clear();

    try {
      // 发送消息
      await ref
          .read(chatControllerProvider.notifier)
          .sendTextMessage(widget.projectId, text, username);

      // 发送后滚动到底部
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollToBottom();
      });
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleSendImage() async {
    // 从 Provider 获取当前用户 ID
    final myUserId = ref.read(currentUserIdProvider);

    // 从成员列表中获取当前用户的 username
    final membersAsyncValue = ref.read(membersProvider(widget.projectId));

    String username = "我"; // 默认值
    membersAsyncValue.whenData((members) {
      final currentMember = members.firstWhere(
        (member) => member.userId == myUserId,
        orElse: () => members.first,
      );
      username = currentMember.username ?? "我";
    });

    _chatController.clear();

    try {
      // 发送图片（实现位于 chat controller）
      await ref
          .read(chatControllerProvider.notifier)
          .sendImageMessage(widget.projectId, username);

      // 发送后滚动到底部
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollToBottom();
      });
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 显示项目详情对话框
  void _showProjectDetail(String detail) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('项目详情'),
        content: SingleChildScrollView(child: Text(detail)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 显示图片消息
  Widget _buildImageMessage(BuildContext context, String imageUrl) {
    final maxBubbleWidth =
        MediaQuery.of(context).size.width * 0.6; // 最大气泡宽度为屏幕宽度的60%
    // 使用 ClipRRect 和 ConstrainedBox 来限制图片大小和圆角
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxBubbleWidth,
          minWidth: 120,
          maxHeight: 280,
          minHeight: 120,
        ),
        // 使用 Image.network 显示图片，并处理加载和错误状态
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            final expected = loadingProgress.expectedTotalBytes;
            final loaded = loadingProgress.cumulativeBytesLoaded;
            final progress = expected != null ? loaded / expected : null;
            return Container(
              color: Colors.grey.shade100,
              alignment: Alignment.center,
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress,
                ),
              ),
            );
          },
          // 错误处理，默认显示一个图片损坏的图标
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.broken_image_outlined,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                  SizedBox(height: 6),
                  Text(
                    '图片加载失败',
                    style: TextStyle(fontSize: 12, color: Colors.redAccent),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectId = widget.projectId;
    final myUserId = ref.watch(currentUserIdProvider);

    final taskViewModel = ref.watch(taskViewModelProvider(projectId).notifier);
    final tasksAsyncValue = ref.watch(taskViewModelProvider(projectId));
    final projectAsyncValue = ref.watch(projectDetailProvider(projectId));
    final membersAsyncValue = ref.watch(membersProvider(projectId));
    final chatMessagesAsync = ref.watch(chatMessagesProvider(projectId));

    // 监听消息列表变化
    ref.listen(chatMessagesProvider(projectId), (previous, next) {
      next.whenData((messages) {
        final hadMessages = previous?.value?.isNotEmpty ?? false;
        final hasNewMessage =
            previous?.value != null &&
            previous!.value!.length < messages.length;

        if (!hadMessages && messages.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          return;
        }

        if (hasNewMessage && _isAtBottom()) {
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,

      // 顶部 AppBar 显示项目标题
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: Colors.black),
        title: projectAsyncValue.when(
          data: (project) => Text(
            project.title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          loading: () => const Text('Loading...'),
          error: (_, __) => const SizedBox(),
        ),
      ),

      // 主体内容，包括项目详情、任务列表和聊天区域
      body: projectAsyncValue.when(
        data: (project) => Column(
          children: [
            // 顶部项目详情
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 描述 (最多显示2行，防止占用太多空间)
                  if (project.description.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            project.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              _showProjectDetail(project.description),
                          child: const Text('全部详情'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  // 成员与日期
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.members,
                          arguments: {
                            'projectId': project.id,
                            'currentUserId':
                                taskViewModel.currentUserId() ?? '',
                            'isOwner': taskViewModel.isOwner(project.ownerId),
                          },
                        ),
                        child: Row(
                          // 成员头像堆叠显示
                          children: [
                            const Text(
                              '成员',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            membersAsyncValue.when(
                              data: (members) =>
                                  MemberAvatars(members: members),
                              loading: () => const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              error: (_, __) => const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatDateRange(project.startAt, project.endAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 剩余空间分配 (1/3 任务 + 2/3 聊天)
            Expanded(
              child: Column(
                children: [
                  // 任务区域 (占 1/3)
                  Expanded(
                    flex: 1, // 权重 1
                    child: Column(
                      children: [
                        // 任务标题栏
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '任务列表',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    TaskShowDialogUtil.showAddTaskDialog(
                                      context: context,
                                      ref: ref,
                                      projectId: projectId,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // 任务列表 (独立滚动)
                        Expanded(
                          child: tasksAsyncValue.when(
                            data: (tasks) {
                              if (tasks.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "暂无任务",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: tasks.length,
                                itemBuilder: (context, index) {
                                  return TaskTile(
                                    task: tasks[index],
                                    projectId: projectId,
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, _) => Center(child: Text('$err')),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 分割线
                  const Divider(
                    thickness: 4,
                    height: 4,
                    color: Color(0xFFF0F0F0),
                  ),

                  // 聊天区域 (占 2/3)
                  Expanded(
                    flex: 2, // 权重 2
                    child: Column(
                      children: [
                        // 聊天标题
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            '团队讨论',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // 消息列表 (独立滚动)
                        Expanded(
                          child: chatMessagesAsync.when(
                            data: (messages) {
                              if (messages.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "暂无消息",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }

                              return Stack(
                                children: [
                                  ListView.builder(
                                    controller: _chatScrollController,
                                    reverse: false, // 顶部旧消息，底部新消息
                                    padding: EdgeInsets.fromLTRB(
                                      16,
                                      10,
                                      16,
                                      _chatInputHeight + 20,
                                    ),
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      // 构建每条消息气泡,区分自己和他人，文字和图片。
                                      // 如果是我的消息是蓝色背景，别人的消息是白色背景
                                      final msg = messages[index];
                                      final isMe = msg.userId == myUserId;
                                      final isImageMessage =
                                          msg.messageType == 'image';
                                      final bubbleColor = isImageMessage
                                          ? Colors.white
                                          : (isMe ? Colors.blue : Colors.white);
                                      final boxBorder = isImageMessage
                                          ? Border.all(
                                              color: Colors.grey.shade200,
                                            )
                                          : (isMe
                                                ? null
                                                : Border.all(
                                                    color: Colors.grey.shade200,
                                                  ));
                                      final bubblePadding = isImageMessage
                                          ? const EdgeInsets.all(8)
                                          : const EdgeInsets.all(12);
                                      // 消息，如果是我的消息右对齐，否则左对齐
                                      return Align(
                                        alignment: isMe
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: bubblePadding,
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: bubbleColor,
                                            border: boxBorder,
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(
                                                16,
                                              ),
                                              topRight: const Radius.circular(
                                                16,
                                              ),
                                              bottomLeft: isMe
                                                  ? const Radius.circular(16)
                                                  : Radius.zero,
                                              bottomRight: isMe
                                                  ? Radius.zero
                                                  : const Radius.circular(16),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.03,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          // 如果消息不是我发的，显示发消息的用户名
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (!isMe)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 4,
                                                      ),
                                                  child: Text(
                                                    msg.username,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              if (isImageMessage)
                                                _buildImageMessage(
                                                  context,
                                                  msg.content,
                                                )
                                              else
                                                Text(
                                                  msg.content,
                                                  style: TextStyle(
                                                    color: isMe
                                                        ? Colors.white
                                                        : Colors.black87,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // 加载更多指示器，显示在顶部，用于指示正在加载更多消息
                                  if (_isLoadingMore)
                                    Positioned(
                                      top: 10,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, _) =>
                                Center(child: Text('Error: $err')),
                          ),
                        ),

                        // 底部输入框 (固定在聊天区域最下方)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          constraints: const BoxConstraints(
                            minHeight: _chatInputHeight,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _chatController,
                                    decoration: InputDecoration(
                                      hintText: '发送消息...',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onSubmitted: (_) => _handleSendMessage(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 发送图片按钮
                                IconButton(
                                  onPressed: _handleSendImage,
                                  icon: const Icon(
                                    Icons.image,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // 发送文字按钮
                                IconButton(
                                  onPressed: _handleSendMessage,
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载项目详情失败: $err')),
      ),
    );
  }
}
