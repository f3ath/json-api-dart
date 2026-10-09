import 'package:json_api/src/document/new_identifier.dart';
import 'package:json_api/src/document/relationship.dart';

class ToMany(Iterable<Identifier> identifiers) extends Relationship {
  this {
    _ids.addAll(identifiers);
  }

  final _ids = <Identifier>[];

  @override
  Map<String, Object?> toJson() => {
    'data': [..._ids],
    ...super.toJson(),
  };

  @override
  Iterator<Identifier> get iterator => _ids.iterator;
}
