import 'dart:collection';

/// A mutable model of URI query parameters.
/// Multiple values per key are supported.
class Query with MapMixin<String, List<String>> {
  final _values = <String, List<String>>{};

  @override
  List<String>? operator [](Object? key) => _values[key];

  @override
  void operator []=(String key, List<String> value) => _values[key] = value;

  @override
  void clear() => _values.clear();

  @override
  Iterable<String> get keys => _values.keys;

  @override
  List<String>? remove(Object? key) => _values.remove(key);
}
