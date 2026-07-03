part of '_function.lib.dart';

abstract class ICpCrypto {
  String sha256(String input);
}

class CpCrypto implements ICpCrypto {
  @override
  String sha256(String input) {
    return crypto.sha256.convert(utf8.encode(input)).toString();
  }
}
