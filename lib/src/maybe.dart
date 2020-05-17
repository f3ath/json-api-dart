/// A variation of the Maybe monad with eager execution.
abstract class Maybe<T> {
  factory Maybe(T value) => value == null ? Nothing<T>() : Just(value);

  /// Maps the value
  Maybe<P> map<P>(P Function(T _) f);

  Maybe<T> filter(bool Function(T _) f);

  T or(T _);

  T orGet(T Function() f);

  T orThrow(Object Function() f);

  void ifPresent(void Function(T _) f);
}

class Just<T> implements Maybe<T> {
  Just(this.value) {
    ArgumentError.checkNotNull(value);
  }

  final T value;

  @override
  Maybe<P> map<P>(P Function(T _) f) => Maybe(f(value));

  @override
  T or(T _) => value;

  @override
  T orGet(T Function() f) => value;

  @override
  T orThrow(Object Function() f) => value;

  @override
  void ifPresent(void Function(T _) f) => f(value);

  @override
  Maybe<T> filter(bool Function(T _) f) => f(value) ? this : Nothing<T>();
}

class Nothing<T> implements Maybe<T> {
  Nothing();

  @override
  Maybe<P> map<P>(P Function(T _) map) => Nothing<P>();

  @override
  T or(T _) => _;

  @override
  T orGet(T Function() f) => f();

  @override
  T orThrow(Object Function() f) => throw f();

  @override
  void ifPresent(void Function(T _) f) {}

  @override
  Maybe<T> filter(bool Function(T _) f) => this;
}
