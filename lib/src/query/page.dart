import 'dart:collection';

/// Query parameters defining the pagination data.
/// @see https://jsonapi.org/format/#fetching-pagination
class Page with MapMixin<String, String> {
  /// Example:
  /// ```dart
  /// Page({'limit': '10', 'offset': '20'}).addTo(url);
  /// ```
  /// encodes into
  /// ```
  /// ?page[limit]=10&page[offset]=20
  /// ```
  ///
  Page([Map<String, String> parameters = const {}]) {
    addAll(parameters);
  }

  static Page fromUri(Uri uri) => Page(uri.queryParametersAll
      .map((k, v) => MapEntry(_regex.firstMatch(k)?.group(1) ?? '', v.last))
        ..removeWhere((k, v) => k.isEmpty));
  static final _regex = RegExp(r'^page\[(.+)\]$');

  final _ = <String, String>{};

  /// Converts to a map of query parameters
  Map<String, String> get asQueryParameters =>
      _.map((k, v) => MapEntry('page[${k}]', v));

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
