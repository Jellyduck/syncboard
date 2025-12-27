import 'package:flutter/material.dart';

import '../models/member_model.dart';

// 项目成员头像层叠显示的组件
class MemberAvatars extends StatelessWidget {
  final List<ProjectMemberModel> members;

  const MemberAvatars({super.key, required this.members});

  static const double _avatarRadius = 16;
  static const double _horizontalSpacing = 20;
  static const int _maxVisible = 4;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCount = members.length > _maxVisible
        ? _maxVisible - 1
        : members.length;
    final extraCount = members.length > _maxVisible
        ? members.length - (_maxVisible - 1)
        : 0;
    final width =
        displayCount * _horizontalSpacing +
        (extraCount > 0 ? _avatarRadius * 2 : 12);

    return SizedBox(
      height: _avatarRadius * 2,
      width: width,
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: i * _horizontalSpacing,
              child: CircleAvatar(
                radius: _avatarRadius,
                backgroundColor: Colors.grey[300],
                backgroundImage: members[i].avatarUrl != null
                    ? NetworkImage(members[i].avatarUrl!)
                    : null,
                child: members[i].avatarUrl == null
                    ? Text(
                        _initialFor(members[i]),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      )
                    : null,
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: displayCount * _horizontalSpacing,
              child: CircleAvatar(
                radius: _avatarRadius,
                backgroundColor: Colors.grey[200],
                child: Text(
                  '+$extraCount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _initialFor(ProjectMemberModel member) {
    final name = member.username?.trim();
    if (name == null || name.isEmpty) {
      return '?';
    }
    return name.substring(0, 1).toUpperCase();
  }
}
