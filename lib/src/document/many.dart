import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_collection.dart';

class ToMany extends Relationship {
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

  /// Finds the referenced elements which are found in the [collection].
  /// The resulting [Iterable] may contain fewer elements than referred by the
  /// relationship if the [collection] does not have all of them.
  Iterable<Resource> findIn(ResourceCollection collection) => collection.where(
      (resource) => any((identifier) => identifier.identifies(resource)));
}
