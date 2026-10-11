import 'dart:collection';

import 'package:json_api/src/query/query_encodable.dart';

/// Query parameters defining filtering.
/// @see https://jsonapi.org/format/#fetching-filtering
/// Example:
/// ```dart
/// Filter({'name': 'John'}).addTo(url);
/// ```
/// encodes into
/// ```
/// ?filter[name]=John
/// ```
class Filter([Map<String, String> parameters = const {}])
    with MapMixin<String, String>
    implements QueryEncodable {
  this {
    addAll(parameters);
  }

  static Filter fromUri(Uri uri) => Filter(
    uri.queryParametersAll.map(
      (k, v) => MapEntry(_regex.firstMatch(k)?.group(1) ?? '', v.last),
    )..removeWhere((k, v) => k.isEmpty),
  );
  static final _regex = RegExp(r'^filter\[(.+)\]$');

  final _ = <String, String>{};

  /// Converts to a map of query parameters
  @override
  Map<String, List<String>> toQuery() =>
      _.map((k, v) => MapEntry('filter[$k]', [v]));

  @override
  String? operator [](Object? key) => _[key];

  @override
  void operator []=(String key, String value) => _[key] = value;

  @override
  void clear() => _.clear();

  @override
  Iterable<String> get keys => _.keys;

  @override
  String? remove(Object? key) => _.remove(key);
}
