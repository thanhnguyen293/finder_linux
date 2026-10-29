/// Outcome of an operation that can fail without throwing.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

enum FailureKind { notFound, permissionDenied, nameTaken, invalidName, other }

/// A failure the UI can localize: [kind] picks the message, [detail] carries
/// the raw OS text or offending name.
class Failure {
  const Failure(this.kind, [this.detail = '']);
  final FailureKind kind;
  final String detail;
}
