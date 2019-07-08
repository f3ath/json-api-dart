import 'dart:collection';

import 'package:json_api/src/query/query_parameters.dart';

class Sort extends QueryParameters with IterableMixin<SortField> {
  final _fields = <SortField>[];

  Sort([Iterable<SortField> fields = const []]) {
    _fields.addAll(fields);
  }

  static Sort decode(Map<String, List<String>> queryParameters) =>
      Sort((queryParameters['sort'] ?? [])
          .expand((_) => _.split(','))
          .map(SortField.parse));

  @override
  Iterator<SortField> get iterator => _fields.iterator;

  Sort desc(String name) => Sort([..._fields, SortField.desc(name)]);

  Sort asc(String name) => Sort([..._fields, SortField.asc(name)]);

  @override
  Map<String, String> get queryParameters => {'sort': join(',')};
}

class SortField {
  final bool isAsc;
  final String name;

  SortField.asc(this.name) : isAsc = true;

  SortField.desc(this.name) : isAsc = false;

  static SortField parse(String str) => str.startsWith('-')
      ? SortField.desc(str.substring(1))
      : SortField.asc(str);

  bool get isDesc => !isAsc;

  @override
  String toString() => (isDesc ? '-' : '') + name;
}
