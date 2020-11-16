import 'dart:collection';

import 'package:json_api/document.dart';

/// A collection of [Identity] objects.
class IdentityCollection<T extends Identity> with IterableMixin<T> {
  IdentityCollection(Iterable<T> resources) {
    resources.forEach((element) => _map[element.key] = element);
  }

  final _map = <String, T>{};

  /// Returns the element by [key] or null.
  T /*?*/ operator [](String key) => _map[key];

  @override
  Iterator<T> get iterator => _map.values.iterator;
}
