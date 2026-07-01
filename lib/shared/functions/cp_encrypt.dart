part of '_function.lib.dart';

abstract class ICpEncrypt {
  String encrypt(String plaintext, String keyBase64);
  String decrypt(String cipherBase64, String keyBase64);
}

class CpEncrypt implements ICpEncrypt {
  @override
  String encrypt(String plaintext, String keyBase64) {
    final key = enc.Key(base64Url.decode(keyBase64));
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    final combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return base64Url.encode(combined);
  }

  @override
  String decrypt(String cipherBase64, String keyBase64) {
    final key = enc.Key(base64Url.decode(keyBase64));
    final allBytes = base64Url.decode(cipherBase64);
    final iv = enc.IV(Uint8List.fromList(allBytes.sublist(0, 16)));
    final cipherBytes = enc.Encrypted(Uint8List.fromList(allBytes.sublist(16)));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.decrypt(cipherBytes, iv: iv);
  }
}
