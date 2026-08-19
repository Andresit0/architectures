import 'package:bcrypt/bcrypt.dart' as bcrypt;
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

class BcryptWrapper implements IPasswordHasher {
  const BcryptWrapper();

  @override
  Future<String> hash(String password) async {
    return bcrypt.BCrypt.hashpw(password, bcrypt.BCrypt.gensalt());
  }
}
