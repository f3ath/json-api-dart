import 'dart:collection';

import 'package:json_api/src/query/query_parameters.dart';

class Include extends QueryParameters with IterableMixin<String> {
  Include(Iterable<String> resources)
      : _resources = [...resources],
        super({'include': resources.join(',')});

  static Include fromUri(Uri uri) =>
      Include((uri.queryParameters['include'] ?? '').split(','));

  Iterator<String> get iterator => _resources.iterator;

  final List<String> _resources;
}
