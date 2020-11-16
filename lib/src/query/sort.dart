import 'dart:collection';

/// Query parameters defining the sorting.
/// @see https://jsonapi.org/format/#fetching-sorting
class Sort with IterableMixin<SortField> {
  /// The [fields] arguments is the list of sorting criteria.
  ///
  /// Example:
  /// ```dart
  /// Sort(['-created', 'title']);
  /// ```
  Sort([Iterable<String> fields = const []]) {
    _.addAll(fields.map((SortField.parse)));
  }

  static Sort fromUri(Uri uri) =>
      Sort((uri.queryParametersAll['sort']?.expand((_) => _.split(',')) ?? []));

  final _ = <SortField>[];

  /// Converts to a map of query parameters
  Map<String, String> get asQueryParameters => {'sort': join(',')};

  @override
  int get length => _.length;

  @override
  Iterator<SortField> get iterator => _.iterator;
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
