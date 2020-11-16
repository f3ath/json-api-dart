import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/relationship.dart';

class Many extends Relationship {
  Many(Iterable<Identifier> identifiers) {
    identifiers.forEach((_) => _map[_.key] = _);
  }

  final _map = <String, Identifier>{};

  @override
  Map<String, Object> toJson() =>
      {'data': _map.values.toList(), ...super.toJson()};

  @override
  Iterator<Identifier> get iterator => _map.values.iterator;
}
