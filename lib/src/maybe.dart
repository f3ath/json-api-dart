/// A variation of the Maybe monad with eager execution.
abstract class Maybe<T> {
  factory Maybe(T t) => t == null ? Nothing<T>() : Just(t);

  Maybe<P> map<P>(P Function(T t) f);

  Maybe<P> whereType<P>();

  Maybe<T> where(bool Function(T t) f);

  T or(T t);

  T orGet(T Function() f);

  T orThrow(Object Function() f);

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
  T or(T t) => value;

  @override
  T orGet(T Function() f) => value;

  @override
  T orThrow(Object Function() f) => value;

  @override
  void ifPresent(Function(T t) f) => f(value);

  @override
  Maybe<T> where(bool Function(T t) f) => f(value) ? this : Nothing<T>();

  @override
  Maybe<P> whereType<P>() => value is P ? Just(value as P) : Nothing<P>();

  @override
  Maybe<T> recover<E>(T Function(E _) f) => this;
}

class Nothing<T> implements Maybe<T> {
  Nothing();

  @override
  Maybe<P> map<P>(P Function(T t) map) => Nothing<P>();

  @override
  T or(T t) => t;

  @override
  T orGet(T Function() f) => f();

  @override
  T orThrow(Object Function() f) => throw f();

  @override
  void ifPresent(Function(T t) f) {}

  @override
  Maybe<T> where(bool Function(T t) f) => this;

  @override
  Maybe<P> whereType<P>() => Nothing<P>();

  @override
  Maybe<T> recover<E>(T Function(E _) f) => this;
}
