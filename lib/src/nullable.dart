_Fun<U, V> nullable<V, U>(U f(V v)) => (v) => v == null ? null : f(v);

typedef U _Fun<U, V>(V v);
