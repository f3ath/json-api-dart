_Fun<U, V> nullable<V, U>(U Function(V v) f) => (v) => v == null ? null : f(v);

typedef _Fun<U, V> = U Function(V v);
