U /*?*/ Function(V /*?*/ v) nullable<V, U>(U Function(V v) f) =>
    (v) => v == null ? null : f(v);
