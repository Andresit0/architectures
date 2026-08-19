import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remember_me_provider.g.dart';

@riverpod
class RememberMe extends _$RememberMe {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}
