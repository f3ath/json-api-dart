extension TypedGetter on Map {
  T get<T>(String key, {T Function() /*?*/ orGet}) {
    if (containsKey(key)) {
      final val = this[key];
      if (val is T) return val;
      throw FormatException(
          'Key "$key": expected $T, found ${val.runtimeType}');
    }
    if (orGet != null) return orGet();
    throw FormatException('Key "$key" does not exist');
  }

  T /*?*/ getNullable<T>(String key, {T /*?*/ Function() /*?*/ orGet}) {
    if (containsKey(key)) {
      final val = this[key];
      if (val is T || val == null) return val;
      throw FormatException(
          'Key "$key": expected $T, found ${val.runtimeType}');
    }
    if (orGet != null) return orGet();
    throw FormatException('Key "$key" does not exist');
  }
}
