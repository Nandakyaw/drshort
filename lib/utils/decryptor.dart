import 'dart:convert';  // For base64.decode
import 'dart:typed_data';  // For Uint8List
import 'package:encrypt/encrypt.dart';

class Decryptor {
  static const _key = '1234567890123456'; // Must match PHP key
  static const _iv = '1234567890123456';  // Must match PHP IV

  static String decrypt(String encryptedText) {
    final key = Key.fromUtf8(_key);
    final iv = IV.fromUtf8(_iv);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

    try {
      // Base64 decode the encrypted string
      final decodedText = base64.decode(encryptedText);

      // Wrap decodedText with Encrypted
      final encrypted = Encrypted(Uint8List.fromList(decodedText));

      // Decrypt the Encrypted data
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      print('Decryption error: $e');
      return '';  // Handle decryption error
    }
  }
}
