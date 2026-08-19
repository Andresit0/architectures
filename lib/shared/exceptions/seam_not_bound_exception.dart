final class SeamNotBoundException extends Error {
  SeamNotBoundException(this.message);

  final String message;

  @override
  String toString() => message;
}
