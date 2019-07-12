import 'dart:collection';

import 'package:json_api/src/query/query_parameters.dart';

class Include extends QueryParameters with IterableMixin<String> {
  final Iterable<String> _resources;

  Include(this._resources);

  factory Include.decode(Map<String, List<String>> query) {
    final resources = (query['include'] ?? []).expand((_) => _.split(','));
    return Include(resources);
  }

  @override
  // TODO: implement iterator
  Iterator<String> get iterator => _resources.iterator;

  @override
  // TODO: implement queryParameters
  Map<String, String> get queryParameters => {'include': join(',')};
}
