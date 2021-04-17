import 'dart:collection';

import 'package:json_api/document.dart';

/// A collection of resources indexed by key.
class ResourceCollection with IterableMixin<Resource> {
  final _map = <String, Resource>{};

  Resource? operator [](Object? key) => _map[key];

  void add(Resource resource) {
    _map[resource.key] = resource;
  }

  void addAll(Iterable<Resource> resources) {
    resources.forEach(add);
  }

  @override
  Iterator<Resource> get iterator => _map.values.iterator;
}
