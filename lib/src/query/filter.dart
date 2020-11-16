import 'dart:collection';

class Filter with MapMixin<String, String> {
  /// Example:
  /// ```dart
  /// Filter({'post': '1,2', 'author': '12'}).addTo(url);
  /// ```
  /// encodes into
  /// ```
  /// ?filter[post]=1,2&filter[author]=12
  /// ```
  Filter([Map<String, String> parameters = const {}]) {
    addAll(parameters);
  }

  static Filter fromUri(Uri uri) => Filter(uri.queryParametersAll
      .map((k, v) => MapEntry(_regex.firstMatch(k)?.group(1) ?? '', v.last))
        ..removeWhere((k, v) => k.isEmpty));

  static final _regex = RegExp(r'^filter\[(.+)\]$');

  final _ = <String, String>{};

  /// Converts to a map of query parameters
  Map<String, String> get asQueryParameters =>
      _.map((k, v) => MapEntry('filter[${k}]', v));

  @override
  String /*?*/ operator [](Object /*?*/ key) => _[key];

  @override
  void operator []=(String key, String value) => _[key] = value;

  @override
  void clear() => _.clear();

  @override
  Iterable<String> get keys => _.keys;

  @override
  String /*?*/ remove(Object /*?*/ key) => _.remove(key);
}
