sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

String failureMessage(Object error) {
  if (error is Failure) return error.message;
  return 'Terjadi kesalahan. Silakan coba lagi.';
}