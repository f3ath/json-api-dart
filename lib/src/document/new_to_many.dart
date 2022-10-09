import 'package:json_api/src/document/new_identifier.dart';
import 'package:json_api/src/document/new_relationship.dart';

class NewToMany extends NewRelationship {
  NewToMany(Iterable<NewIdentifier> identifiers) {
    _ids.addAll(identifiers);
  }

  final _ids = <NewIdentifier>[];

  @override
  Map<String, Object> toJson() => {
        'data': [..._ids],
        ...super.toJson()
      };

  @override
  Iterator<NewIdentifier> get iterator => _ids.iterator;
}
