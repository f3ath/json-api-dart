import 'dart:collection';

import 'package:json_api/src/query/query_parameters.dart';

class Sort extends QueryParameters with IterableMixin<SortField> {
  final _fields = <SortField>[];

  Sort([Iterable<SortField> fields = const []]) {
    _fields.addAll(fields);
  }

  static Sort fromUri(Uri uri) =>
      Sort((uri.queryParameters['sort'] ?? '').split(',').map(SortField.parse));

  @override
  Iterator<SortField> get iterator => _fields.iterator;

  Sort desc(String name) => Sort([..._fields, SortField.desc(name)]);

  Sort asc(String name) => Sort([..._fields, SortField.asc(name)]);

  @override
  Map<String, String> get queryParameters => {'sort': join(',')};
}

class SortField {
  static final _descPrefix = '-';

  final bool isAsc;
  final bool isDesc;
  final String name;

  SortField.asc(this.name)
      : isAsc = true,
        isDesc = false;

  SortField.desc(this.name)
      : isAsc = false,
        isDesc = true;

  static SortField parse(String queryParam) =>
      queryParam.startsWith(_descPrefix)
          ? SortField.desc(queryParam.substring(1))
          : SortField.asc(queryParam);

  @override
  String toString() => (isDesc ? _descPrefix : '') + name;
}
