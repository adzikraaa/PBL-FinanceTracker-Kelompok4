class Note {
  final String id;
  String title;
  String content;
  DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  // Untuk keperluan dummy text yg di potong
  String get excerpt {
    if (content.length > 80) {
      return '${content.substring(0, 80)}...';
    }
    return content;
  }
}
