import 'package:encrypt/encrypt.dart' as encrypt;

class Episode {
  final int episodeNumber;
  final String episodeTitle;
  final String encryptedEpisodeUrl;

  Episode({
    required this.episodeNumber,
    required this.episodeTitle,
    required this.encryptedEpisodeUrl
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeNumber: json['episode_number'],
      episodeTitle: json['episode_title'],
      encryptedEpisodeUrl: json['episode_url'],
    );
  }

  String getDecryptedUrl() {
    final key = encrypt.Key.fromUtf8('1234567890123456'); // 16 characters for AES-128
    final iv = encrypt.IV.fromUtf8('1234567890123456');   // 16 characters IV
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));

    try {
      final decrypted = encrypter.decrypt64(encryptedEpisodeUrl, iv: iv);
      return decrypted;
    } catch (e) {
      print('Decryption error: $e');
      return 'Decryption failed';
    }
  }
}
