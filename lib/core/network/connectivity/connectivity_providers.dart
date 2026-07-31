import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_connectivity_checker.dart';
import 'package:clean_architecture_sdd_harness/core/network/connectivity/internet_service.dart';
import 'package:clean_architecture_sdd_harness/core/network/connectivity/server_reachability_strategy.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final internetServiceProvider = Provider<IInternetService>((ref) {
  final env = AppEnvironment.current;
  return InternetService(
    strategy: kIsWeb
        ? HttpReachability(
            dio: Dio()
              ..options.connectTimeout = const Duration(seconds: 5)
              ..options.receiveTimeout = const Duration(seconds: 5),
            baseUri: Uri(
              scheme: 'https',
              host: env.host,
              port: env.port,
            ),
          )
        : NativeSocketReachability(
            host: env.host,
            port: env.port,
          ),
  );
});

final connectivityCheckerProvider = Provider<IConnectivityChecker>(
    (ref) => ref.watch(internetServiceProvider));
