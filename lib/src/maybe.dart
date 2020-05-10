/// A variation of the Maybe monad with eager execution.
abstract class Maybe<T> {
  factory Maybe(T t) => t == null ? Nothing() : Just(t);

  Maybe<P> map<P>(P Function(T t) f);

  Maybe<P> whereType<P>();

  Maybe<T> where(bool Function(T t) f);

  T or(T Function() f);

  void ifPresent(Function(T t) f);

  Maybe<T> recover<E>(T Function(E _) f);
}

class Just<T> implements Maybe<T> {
  Just(this.value) {
    ArgumentError.checkNotNull(value);
  }

  final T value;

  @override
  Maybe<P> map<P>(P Function(T t) f) => Maybe(f(value));

  @override
  T or(T Function() f) => value;

  @override
  void ifPresent(Function(T t) f) => f(value);

  @override
  Maybe<T> where(bool Function(T t) f) {
    try {
      return f(value) ? this : const Nothing();
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Maybe<P> whereType<P>() => value is P ? Just(value as P) : const Nothing();

  @override
  Maybe<T> recover<E>(T Function(E _) f) => this;
}

class Nothing<T> implements Maybe<T> {
  const Nothing();

  @override
  Maybe<P> map<P>(P Function(T t) map) => const Nothing();

  @override
  T or(T Function() f) => f();

  @override
  void ifPresent(Function(T t) f) {}

  @override
  Maybe<T> where(bool Function(T t) f) => this;

  @override
  Maybe<P> whereType<P>() => const Nothing();

  @override
  Maybe<T> recover<E>(T Function(E _) f) => this;
}

class Failure<T> implements Maybe<T> {
  const Failure(this.exception);

  final Object exception;

  @override
  void ifPresent(Function(T t) f) {}

  @override
  Maybe<P> map<P>(P Function(T t) f) => this as Failure<P>;

  @override
  T or(T Function() f) => f();

  @override
  Maybe<T> where(bool Function(T t) f) => this;

  @override
  Maybe<P> whereType<P>() => this as Failure<P>;

  @override
  Maybe<T> recover<E>(T Function(E _) f) =>
      exception is E ? Maybe(f(exception as E)) : this;
}
