import 'dart:collection';

import 'package:json_api/src/query/query_parameters.dart';

class Include extends QueryParameters with IterableMixin<String> {
  final Iterable<String> _resources;

  Include(this._resources);

  factory Include.fromUri(Uri uri) =>
      Include((uri.queryParameters['include'] ?? '').split(','));

  @override
  Iterator<String> get iterator => _resources.iterator;

  @override
  Map<String, String> get queryParameters => {'include': join(',')};
}
