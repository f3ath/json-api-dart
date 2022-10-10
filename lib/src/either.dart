/// A simple ad-hoc implementation of the Either monad.
abstract class Either<L, R> {
  /// Creates a [Either] with the left side defined.
  static Either<L, R> left<L, R>(L value) => _Left(value);

  /// Creates an [Either] with the left side defined.
  static Either<L, R> right<L, R>(R value) => _Right(value);

  /// Resolves the content to a single type.
  T resolve<T>(T Function(L) left, T Function(R) right);
}

class _Left<L, R> implements Either<L, R> {
  _Left(this.value);

  final L value;

  @override
  T resolve<T>(T Function(L p1) left, T Function(R p1) right) => left(value);
}

class _Right<L, R> implements Either<L, R> {
  _Right(this.value);

  final R value;

  @override
  T resolve<T>(T Function(L p1) left, T Function(R p1) right) => right(value);
}
