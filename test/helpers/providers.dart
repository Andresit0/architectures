import 'package:riverpod_annotation/riverpod_annotation.dart';

ProviderContainer buildContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(overrides: overrides);
}
