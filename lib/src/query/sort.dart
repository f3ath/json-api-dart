import 'dart:collection';

import 'package:json_api/src/query/query_encodable.dart';

/// Query parameters defining the sorting.
/// @see https://jsonapi.org/format/#fetching-sorting
class Sort with IterableMixin<SortField> implements QueryEncodable {
  /// The [fields] arguments is the list of sorting criteria.
  ///
  /// Example:
  /// ```dart
  /// Sort(['-created', 'title']);
  /// ```
  Sort([Iterable<String> fields = const []]) {
    _fields.addAll(fields.map((SortField.parse)));
  }

  static Sort fromUri(Uri uri) => Sort(
      (uri.queryParametersAll['sort']?.expand((it) => it.split(',')) ?? []));

  final _fields = <SortField>[];

  /// Converts to a map of query parameters
  @override
  Map<String, List<String>> toQuery() => {
        if (isNotEmpty) 'sort': [join(',')]
      };

  @override
  int get length => _fields.length;

  @override
  Iterator<SortField> get iterator => _fields.iterator;
}

abstract class SortField {
  static SortField parse(String queryParam) => queryParam.startsWith('-')
      ? Desc(queryParam.substring(1))
      : Asc(queryParam);

  String get name;

  /// Returns 1 for Ascending fields, -1 for Descending
  int get factor;
}

class Asc implements SortField {
  const Asc(this.name);

  @override
  final String name;

  @override
  final int factor = 1;

  @override
  String toString() => name;
}

class Desc implements SortField {
  const Desc(this.name);

  @override
  final String name;

  @override
  final int factor = -1;

  @override
  String toString() => '-$name';
}
