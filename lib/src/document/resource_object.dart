import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/identifier_object_collection.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/nullable.dart';

class ResourceObject implements PrimaryData {
  final String type;
  final String id;
  final attributes = <String, Object>{};
  final relationships = <String, Relationship>{};

  ResourceObject(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Relationship> relationships}) {
    this.attributes.addAll(attributes ?? {});
    this.relationships.addAll(relationships ?? {});
  }

  Map<String, Link> get links => {};

  static ResourceObject fromResource(Resource resource) {
    final relationships = <String, Relationship>{};
    resource.toOne.forEach((k, v) =>
        relationships[k] = Relationship(IdentifierObject.fromIdentifier(v)));

    resource.toMany.forEach((k, v) => relationships[k] = Relationship(
        IdentifierObjectCollection(
            v.map(nullable(IdentifierObject.fromIdentifier)))));

    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes, relationships: relationships);
  }

  toJson() => {
        'type': type,
        'id': id,
        'attributes': attributes,
        'relationships': relationships
      };

  Resource toResource() {
    final toOne = <String, Identifier>{};
    final toMany = <String, List<Identifier>>{};
    relationships.forEach((name, rel) {
      final data = rel.data;
      // TODO: detect incomplete relationships
      if (data is IdentifierObject) {
        toOne[name] = data.toIdentifier();
      } else if (data is IdentifierObjectCollection) {
        toMany[name] = data.toIdentifiers();
      }
    });

    return Resource(type, id,
        attributes: attributes, toOne: toOne, toMany: toMany);
  }
}
