/// Makes the keys lowercase, wraps to unmodifiable map
Map<String, String> normalize(Map<String, String> headers) => Map.unmodifiable(
    (headers ?? const {}).map((k, v) => MapEntry(k.toLowerCase(), v)));
