class ChatMessageModel {
  final String id;
  final String content;
  final String userId;
  final DateTime createdAt;
  final String username;
  final String messageType;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.username,
    required this.messageType,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'].toString(),
      content: json['content'] ?? '',
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      username: json['username'] ?? 'Unknown',
      messageType: json['message_type'] ?? 'text',
    );
  }
}
