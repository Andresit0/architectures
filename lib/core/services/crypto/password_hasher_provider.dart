import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'bcrypt_wrapper.dart';

final passwordHasherProvider = Provider<IPasswordHasher>(
  (ref) => const BcryptWrapper(),
);
