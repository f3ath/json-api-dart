import 'dart:collection';

import 'package:json_api/src/query/query_parameters.dart';

class Sort extends QueryParameters with IterableMixin<SortField> {
  static Sort fromUri(Uri uri) =>
      Sort((uri.queryParameters['sort'] ?? '').split(',').map(SortField.parse));

  Sort([Iterable<SortField> fields = const []])
      : _fields = [...fields],
        super({'sort': fields.join(',')});

  @override
  Iterator<SortField> get iterator => _fields.iterator;

  Sort desc(String name) => Sort([..._fields, Desc(name)]);

  Sort asc(String name) => Sort([..._fields, Asc(name)]);

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
