sealed class RetryResult {
  const RetryResult();
}

final class RetrySuccess extends RetryResult {
  const RetrySuccess(this.token);
  final String token;
}

final class RetryNoConnection extends RetryResult {
  const RetryNoConnection();
}

final class RetryFailed extends RetryResult {
  const RetryFailed();
}
