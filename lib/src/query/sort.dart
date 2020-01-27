import 'dart:collection';

import 'package:json_api/src/query/query_parameters.dart';

/// Query parameters defining the sorting.
/// @see https://jsonapi.org/format/#fetching-sorting
class Sort extends QueryParameters with IterableMixin<SortField> {
  /// The [fields] arguments is the list of sorting criteria.
  /// Use [Asc] and [Desc] to define sort direction.
  ///
  /// Example:
  /// ```dart
  /// Sort([Asc('created'), Desc('title')]).addTo(url);
  /// ```
  /// encodes into
  /// ```
  /// ?sort=-created,title
  /// ```
  Sort(Iterable<SortField> fields)
      : _fields = [...fields],
        super({'sort': fields.join(',')});

  static Sort fromUri(Uri uri) =>
      Sort((uri.queryParametersAll['sort']?.expand((_) => _.split(',')) ?? [])
          .map(SortField.parse));

  @override
  Iterator<SortField> get iterator => _fields.iterator;

  final List<SortField> _fields;
}

class SortField {
  final bool isAsc;

  final bool isDesc;

  final String name;

  /// Returns 1 for Ascending fields, -1 for Descending
  int get comparisonFactor => isAsc ? 1 : -1;

  @override
  String toString() => isAsc ? name : '-$name';

  SortField.Asc(this.name)
      : isAsc = true,
        isDesc = false;

  SortField.Desc(this.name)
      : isAsc = false,
        isDesc = true;

  static SortField parse(String queryParam) => queryParam.startsWith('-')
      ? Desc(queryParam.substring(1))
      : Asc(queryParam);
}

class Asc extends SortField {
  Asc(String name) : super.Asc(name);
}

class Desc extends SortField {
  Desc(String name) : super.Desc(name);
}
