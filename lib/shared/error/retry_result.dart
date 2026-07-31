sealed class RetryResult {
  const RetryResult();
}

class RetrySuccess extends RetryResult {
  const RetrySuccess(this.token);
  final String token;
}

class RetryNoConnection extends RetryResult {
  const RetryNoConnection();
}

class RetryFailed extends RetryResult {
  const RetryFailed();
}
