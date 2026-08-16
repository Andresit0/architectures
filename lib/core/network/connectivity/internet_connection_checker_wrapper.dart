import 'package:clean_architecture_sdd_harness/core/network/connectivity/i_internet_connection_checker_wrapper.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetConnectionCheckerWrapper
    implements IInternetConnectionCheckerWrapper {
  const InternetConnectionCheckerWrapper();

  @override
  Future<bool> checkConnectivity() async {
    final result = await InternetConnection().internetStatus;
    return result == InternetStatus.connected;
  }

  @override
  Stream<bool> get onStatusChange => InternetConnection().onStatusChange.map(
    (status) => status == InternetStatus.connected,
  );
}
