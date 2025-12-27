class Task {
  final String id;
  final String projectId;
  final String title;
  final bool isCompleted;
  final int orderIndex;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.isCompleted,
    required this.orderIndex,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      projectId: json['project_id'],
      title: json['title'],
      isCompleted: json['is_completed'] ?? false,
      orderIndex: json['order_index'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'title': title,
      'is_completed': isCompleted,
      'order_index': orderIndex,
    };
  }

  Task copyWith({bool? isCompleted, String? title}) {
    return Task(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex,
      createdAt: createdAt,
    );
  }
}
