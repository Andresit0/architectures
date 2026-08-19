import 'package:clean_architecture_sdd_harness/core/database/database_encrypt.dart';
import 'package:sembast/sembast.dart';

const _encryptCodecSignature = 'encrypt';

SembastCodec getEncryptSembastCodec({required String password}) => SembastCodec(
  signature: _encryptCodecSignature,
  codec: buildEncryptCodec(password),
);
