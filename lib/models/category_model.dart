class CategoryModel {
  final String id;
  final String title;
  final String iconName;
  final int taskCount; // 来自视图的统计字段

  CategoryModel({
    required this.id,
    required this.title,
    required this.iconName,
    required this.taskCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      title: json['title'],
      iconName: json['icon_name'] ?? 'default', // 只有 view 里有这个字段
      // 视图里的 count 可能是 int 也可能是 long
      taskCount: json['task_count'] != null ? json['task_count'] as int : 0,
    );
  }
}
