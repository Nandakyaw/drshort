// models/episode_model.dart

class Episode {
  final int episodeNumber;
  final String episodeTitle;
  final String episodeUrl;

  Episode({required this.episodeNumber, required this.episodeTitle, required this.episodeUrl});

  // Factory method to create an Episode object from JSON
  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeNumber: json['episode_number'],
      episodeTitle: json['episode_title'],
      episodeUrl: json['episode_url'],
    );
  }
}
