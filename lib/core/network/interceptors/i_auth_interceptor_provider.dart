import 'package:clean_architecture_sdd_harness/core/network/dio/dio_wrapper.dart';

abstract interface class IAuthInterceptorProvider {
  void setupAuthInterceptor(IDioWrapper dioWrapper);
}
