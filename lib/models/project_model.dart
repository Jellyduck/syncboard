class ProjectModel {
  final String id;
  final String categoryId;
  final String ownerId;
  final String title;
  final String description;
  final DateTime? startAt;
  final DateTime? endAt;
  final int memberCount;
  final String status;

  ProjectModel({
    required this.id,
    required this.categoryId,
    required this.ownerId,
    required this.title,
    required this.description,
    this.startAt,
    this.endAt,
    required this.memberCount,
    required this.status,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      categoryId: json['category_id'],
      ownerId: json['owner_id'],
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      startAt: json['start_at'] != null
          ? DateTime.parse(json['start_at'])
          : null,
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
      memberCount: json['member_count'] ?? 0,
      status: json['status'] ?? 'ongoing',
    );
  }
}
