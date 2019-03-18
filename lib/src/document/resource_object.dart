import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/nullable.dart';

/// [ResourceObject] is a JSON representation of a [Resource].
///
/// It carries all JSON-related logic and the Meta-data.
/// In a JSON:API Document it can be the value of the `data` member (a `data`
/// member element in case of a collection) or a member of the `included`
/// resource collection.
///
/// More on this: https://jsonapi.org/format/#document-resource-objects
class ResourceObject {
  final String type;
  final String id;
  final Link self;
  final attributes = <String, Object>{};
  final relationships = <String, Relationship>{};

  ResourceObject(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Relationship> relationships,
      this.self}) {
    this.attributes.addAll(attributes ?? {});
    this.relationships.addAll(relationships ?? {});
  }

  static ResourceObject fromResource(Resource resource) {
    final relationships = <String, Relationship>{}
      ..addAll(resource.toOne.map((k, v) =>
          MapEntry(k, ToOne(nullable(IdentifierObject.fromIdentifier)(v)))))
      ..addAll(resource.toMany.map((k, v) =>
          MapEntry(k, ToMany(v.map(IdentifierObject.fromIdentifier)))));

    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes, relationships: relationships);
  }

  /// Returns the JSON object to be used in the `data` or `included` members
  /// of a JSON:API Document
  Map<String, Object> toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (attributes.isNotEmpty) {
      json['attributes'] = attributes;
    }
    if (relationships.isNotEmpty) {
      json['relationships'] = relationships;
    }
    if (self != null) {
      json['links'] = {'self': self};
    }
    return json;
  }

  /// Converts to [Resource] if possible. The standard allows relationships
  /// without `data` member. In this case the original [Resource] can not be
  /// recovered and this method will throw a [StateError].
  ///
  /// TODO: we probably need `isIncomplete` flag to check for this.
  Resource toResource() {
    final toOne = <String, Identifier>{};
    final toMany = <String, List<Identifier>>{};
    final incomplete = <String, Relationship>{};
    relationships.forEach((name, rel) {
      if (rel is ToOne) {
        toOne[name] = rel.toIdentifier();
      } else if (rel is ToMany) {
        toMany[name] = rel.toIdentifiers().toList();
      } else {
        incomplete[name] = rel;
      }
    });

    if (incomplete.isNotEmpty) {
      throw StateError('Can not convert to resource'
          ' due to incomplete relationships data: ${incomplete.keys}');
    }

    return Resource(type, id,
        attributes: attributes, toOne: toOne, toMany: toMany);
  }
}
