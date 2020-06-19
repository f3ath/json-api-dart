import 'dart:collection';

import 'package:json_api_common/document.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class IdentityCollection<T extends Identity> with IterableMixin<T> {
  IdentityCollection(Iterable<T> resources)
      : _map = Map<String, T>.fromIterable(resources, key: (_) => _.key);

  final Map<String, T> _map;

  Maybe<T> get(String key) => Maybe(_map[key]);

  @override
  Iterator<T> get iterator => _map.values.iterator;
}
