class PostModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String? duration; // nullable
  final String? photo;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.duration,
    this.photo,
    required this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as int,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      duration: map['duration'], // can be null
      photo: map['photo'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
