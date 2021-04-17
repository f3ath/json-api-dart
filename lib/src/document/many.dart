import 'package:json_api/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_collection.dart';

class ToMany extends Relationship {
  ToMany(Iterable<Identifier> identifiers) {
    identifiers.forEach((_) => _map[_.key] = _);
  }

  final _map = <String, Identifier>{};

  @override
  Map<String, Object> toJson() =>
      {'data': _map.values.toList(), ...super.toJson()};

  @override
  Iterator<Identifier> get iterator => _map.values.iterator;

  /// Finds the referenced elements which are found in the [collection].
  /// The resulting [Iterable] may contain fewer elements than referred by the
  /// relationship if the [collection] does not have all of them.
  Iterable<Resource> findIn(ResourceCollection collection) {
    return _map.keys.map((key) => collection[key]).whereType();
  }
}
