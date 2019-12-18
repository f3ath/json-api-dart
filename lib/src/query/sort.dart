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
      Sort((uri.queryParameters['sort'] ?? '').split(',').map(SortField.parse));

  @override
  Iterator<SortField> get iterator => _fields.iterator;

  final List<SortField> _fields;
}

abstract class SortField {
  bool get isAsc;

  bool get isDesc;

  String get name;

  static SortField parse(String queryParam) => queryParam.startsWith('-')
      ? Desc(queryParam.substring(1))
      : Asc(queryParam);
}

class Asc implements SortField {
  Asc(this.name);

  @override
  bool get isAsc => true;

  @override
  bool get isDesc => false;

  @override
  final String name;

  @override
  String toString() => name;
}

class Desc implements SortField {
  Desc(this.name);

  @override
  bool get isAsc => false;

  @override
  bool get isDesc => true;

  @override
  final String name;

  @override
  String toString() => '-${name}';
}
