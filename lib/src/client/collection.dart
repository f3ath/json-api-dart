import 'dart:collection';

import 'package:json_api/core.dart';
import 'package:json_api/document.dart';

/// A collection of objects indexed by ref.
class ResourceCollection with IterableMixin<Resource> {
  final _map = <Ref, Resource>{};

  Resource? operator [](Object? key) => _map[key];

  void add(Resource resource) {
    _map[resource.ref] = resource;
  }

  void addAll(Iterable<Resource> resources) {
    resources.forEach(add);
  }

  @override
  Iterator<Resource> get iterator => _map.values.iterator;
}
