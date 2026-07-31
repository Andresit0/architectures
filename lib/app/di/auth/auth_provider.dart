import 'package:clean_architecture_sdd_harness/core/services/auth/auth_observer.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_state.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_authentication_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_notifier.dart';

final authenticationObserverProvider = Provider<IAuthenticationObserver>((ref) {
  final observer = AuthObserver();
  final currentState = ref.read(authProvider);
  observer.update(currentState is AuthLoaded);
  ref.listen(authProvider, (_, next) {
    if (next is AuthInitial) {
      observer.update(false);
    } else if (next is AuthLoaded) {
      observer.update(true);
    }
  });
  return observer;
});
