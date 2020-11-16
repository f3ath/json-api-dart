import 'dart:collection';

/// HTTP headers. All keys are converted to lowercase on the fly.
class Headers with MapMixin<String, String> {
  Headers([Map<String, String> headers = const {}]) {
    addAll(headers);
  }

  final _ = <String, String>{};

  @override
  String /*?*/ operator [](Object /*?*/ key) =>
      key is String ? _[_convert(key)] : null;

  @override
  void operator []=(String key, String value) => _[_convert(key)] = value;

  @override
  void clear() => _.clear();

  @override
  Iterable<String> get keys => _.keys;

  @override
  String /*?*/ remove(Object /*?*/ key) =>
      _.remove(key is String ? _convert(key) : key);

  String _convert(String s) => s.toLowerCase();
}
