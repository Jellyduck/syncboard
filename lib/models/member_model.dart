class ProjectMemberModel {
  final String id;
  final String projectId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String? avatarUrl;
  final String? username;

  ProjectMemberModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.avatarUrl,
    this.username,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    return ProjectMemberModel(
      id: json['id'],
      projectId: json['project_id'],
      userId: json['user_id'],
      role: json['role'] ?? 'member',
      joinedAt: DateTime.parse(json['joined_at']),
      avatarUrl: profile?['avatar_url'],
      username: profile?['username'],
    );
  }
}
