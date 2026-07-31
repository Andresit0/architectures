import 'package:bcrypt/bcrypt.dart' as bcrypt;
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_password_hasher.dart';

class BcryptWrapper implements IPasswordHasher {
  const BcryptWrapper();

  @override
  Future<String> hash(String password) async {
    return bcrypt.BCrypt.hashpw(password, bcrypt.BCrypt.gensalt());
  }

  @override
  Future<bool> verify(String password, String hash) async {
    return bcrypt.BCrypt.checkpw(password, hash);
  }
}
