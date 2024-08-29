class Series {
  final String id;
  final String title;
  final String poster;
  final DateTime createdAt; // Add this field

  Series({required this.id, required this.title, required this.poster, required this.createdAt});

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'],
      title: json['title'],
      poster: json['poster'],
      createdAt: DateTime.parse(json['created_at']), // Parse the date string
    );
  }
}
