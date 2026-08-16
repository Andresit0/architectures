import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
// ignore: implementation_imports
import 'package:sembast/src/api/v2/sembast.dart';

Uint8List _randBytes(int length) {
  final secureRandom = Random.secure();
  return Uint8List.fromList(
    List.generate(length, (_) => secureRandom.nextInt(256)),
  );
}

Uint8List _generateEncryptPassword(String password) {
  final blob = Uint8List.fromList(sha256.convert(utf8.encode(password)).bytes);
  assert(blob.length == 32);
  return blob;
}

class _EncryptEncoder extends Converter<Object?, String> {
  _EncryptEncoder(this.encrypter);
  final Encrypter encrypter;

  @override
  String convert(dynamic input) {
    final iv = _randBytes(16);
    final ivEncoded = base64.encode(iv);
    final encoded = encrypter.encrypt(json.encode(input), iv: IV(iv)).base64;
    return '$ivEncoded$encoded';
  }
}

class _EncryptDecoder extends Converter<String, Object?> {
  _EncryptDecoder(this.encrypter);
  final Encrypter encrypter;

  @override
  dynamic convert(String input) {
    try {
      const ivSize = 24;
      if (input.length < ivSize) {
        throw const FormatException('Input too short to contain IV');
      }
      final iv = base64.decode(input.substring(0, ivSize));
      final encrypted = input.substring(ivSize);
      final decrypted = encrypter.decrypt64(encrypted, iv: IV(iv));
      final decoded = json.decode(decrypted);
      if (decoded is Map) {
        return decoded.cast<String, Object?>();
      }
      return decoded;
    } catch (e) {
      throw FormatException('Failed to decrypt data: $e');
    }
  }
}

class _EncryptCodec extends Codec<Object?, String> {
  _EncryptCodec(Uint8List passwordBytes) {
    assert(passwordBytes.length == 32, 'AES-256 requires a 32-byte key');
    final key = Key(passwordBytes);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    _encoder = _EncryptEncoder(encrypter);
    _decoder = _EncryptDecoder(encrypter);
  }
  late _EncryptEncoder _encoder;
  late _EncryptDecoder _decoder;

  @override
  Converter<String, Object?> get decoder => _decoder;

  @override
  Converter<Object?, String> get encoder => _encoder;
}

const _encryptCodecSignature = 'encrypt';

SembastCodec getEncryptSembastCodec({required String password}) => SembastCodec(
  signature: _encryptCodecSignature,
  codec: _EncryptCodec(_generateEncryptPassword(password)),
);
