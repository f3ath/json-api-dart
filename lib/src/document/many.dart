import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/relationship.dart';

class ToMany extends Relationship<Identifier> {
  ToMany(Iterable<Identifier> identifiers) {
    _ids.addAll(identifiers);
  }

  final _ids = <Identifier>[];

  @override
  Map<String, Object> toJson() => {
        'data': [..._ids],
        ...super.toJson()
      };

  @override
  Iterator<Identifier> get iterator => _ids.iterator;
}
