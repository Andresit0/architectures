import 'package:flutter_riverpod/flutter_riverpod.dart';

class RememberMeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final rememberMeProvider = NotifierProvider<RememberMeNotifier, bool>(
  RememberMeNotifier.new,
);
