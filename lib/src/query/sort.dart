import 'dart:collection';

import 'package:json_api/src/query/add_to_uri.dart';

class Sort with AddToUri, IterableMixin<SortField> implements AddToUri {
  static Sort fromUri(Uri uri) =>
      Sort((uri.queryParameters['sort'] ?? '').split(',').map(SortField.parse));

  final _fields = <SortField>[];

  Sort([Iterable<SortField> fields = const []]) {
    _fields.addAll(fields);
  }

  @override
  Iterator<SortField> get iterator => _fields.iterator;

  Sort desc(String name) => Sort([..._fields, Descending(name)]);

  Sort asc(String name) => Sort([..._fields, Ascending(name)]);

  @override
  Map<String, String> get queryParameters => {'sort': join(',')};
}

abstract class SortField {
  bool get isAsc;

  bool get isDesc;

  String get name;

  static SortField parse(String queryParam) => queryParam.startsWith('-')
      ? Descending(queryParam.substring(1))
      : Ascending(queryParam);
}

class Ascending implements SortField {
  Ascending(this.name);

  @override
  bool get isAsc => true;

  @override
  bool get isDesc => false;

  @override
  final String name;

  @override
  String toString() => name;
}

class Descending implements SortField {
  Descending(this.name);

  @override
  bool get isAsc => false;

  @override
  bool get isDesc => true;

  @override
  final String name;

  @override
  String toString() => '-${name}';
}
