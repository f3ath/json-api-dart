import 'dart:collection';

import 'package:json_api/src/query/query.dart';

/// Query parameters defining Sparse Fieldsets
/// @see https://jsonapi.org/format/#fetching-sparse-fieldsets
class Fields with MapMixin<String, Iterable<String>> implements Query {
  /// The [fields] argument maps the resource type to a list of fields.
  ///
  /// Example:
  /// ```dart
  /// Fields({'articles': ['title', 'body'], 'people': ['name']});
  /// ```
  Fields([Map<String, Iterable<String>> fields = const {}]) {
    addAll(fields);
  }

  /// Extracts the requested fields from the [uri].
  static Fields fromUri(Uri uri) =>
      Fields(uri.queryParametersAll.map((k, v) => MapEntry(
          _regex.firstMatch(k)?.group(1) ?? '',
          v.expand((_) => _.split(',')).toList()))
        ..removeWhere((k, v) => k.isEmpty));

  static final _regex = RegExp(r'^fields\[(.+)\]$');

  final _map = <String, Iterable<String>>{};

  /// Converts to a map of query parameters
  @override
  Map<String, List<String>> toQuery() =>
      _map.map((k, v) => MapEntry('fields[$k]', [v.join(',')]));

  @override
  void operator []=(String key, Iterable<String> value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;

  @override
  Iterable<String>? remove(Object? key) => _map.remove(key);

  @override
  Iterable<String>? operator [](Object? key) => _map[key];
}
