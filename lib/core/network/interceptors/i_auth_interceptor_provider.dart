import 'package:clean_architecture_sdd_harness/core/network/dio/dio_wrapper.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

abstract interface class IAuthInterceptorProvider {
  void setupAuthInterceptor(IDioWrapper dioWrapper, {required VoidCallback onForceLogout});
}
