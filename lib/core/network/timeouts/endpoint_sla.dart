import 'package:clean_architecture_sdd_harness/core/network/retry/retry_policy.dart';

enum EndpointSla {
  urgent(Duration(seconds: 5), RetryPolicy.standard),
  standard(Duration(seconds: 15), RetryPolicy.standard),
  login(Duration(seconds: 30), RetryPolicy.standard),
  upload(Duration(seconds: 120), RetryPolicy.idempotent),
  unknown(Duration(seconds: 10), RetryPolicy.standard);

  final Duration timeout;
  final RetryPolicy retry;
  const EndpointSla(this.timeout, this.retry);
}
