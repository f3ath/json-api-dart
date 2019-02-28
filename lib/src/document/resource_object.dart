import 'package:json_api/src/identifier.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/resource.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';

/// Resource object
class ResourceObject {
  final String type;
  final String id;
  final Link self;
  final Map<String, Object> attributes;
  final Map<String, Object> meta;
  final Map<String, Relationship> relationships;

  ResourceObject(this.type, this.id,
      {this.self,
      Map<String, Object> meta,
      Map<String, Object> attributes,
      Map<String, Relationship> relationships})
      : meta = Map.unmodifiable(meta ?? {}),
        attributes = Map.unmodifiable(attributes ?? {}),
        relationships = Map.unmodifiable(relationships ?? {});

  Resource toResource() {
    final toOne = <String, Identifier>{};
    final toMany = <String, List<Identifier>>{};
    relationships.forEach((name, rel) {
      if (rel is ToOne) {
        toOne[name] = rel.toIdentifier();
      } else if (rel is ToMany) {
        toMany[name] = rel.toIdentifiers();
      }
    });
    return Resource(type, id,
        attributes: attributes, toMany: toMany, toOne: toOne);
  }

  static ResourceObject fromResource(Resource r) {
    final toOne = r.toOne.map((name, v) =>
        MapEntry(name, ToOne(nullable(IdentifierObject.fromIdentifier)(v))));

    final toMany = r.toMany.map((name, v) => MapEntry(
        name,
        ToMany(
          v.map(nullable(IdentifierObject.fromIdentifier)).toList(),
        )));

    return ResourceObject(r.type, r.id,
        attributes: r.attributes,
        relationships: <String, Relationship>{}..addAll(toOne)..addAll(toMany));
  }

  static ResourceObject fromJson(Object json) {
    if (json is Map) {
      final links = Link.parseMap(json['links'] ?? {});

      return ResourceObject(
        json['type'],
        json['id'],
        attributes: json['attributes'],
        self: links['self'],
        meta: json['meta'],
        relationships: Relationship.parseMap(json['relationships'] ?? {}),
      );
    }
    throw 'Can not parse ResourceContainer from $json';
  }

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (attributes.isNotEmpty) json['attributes'] = attributes;
    if (relationships.isNotEmpty) json['relationships'] = relationships;
    if (meta.isNotEmpty) json['meta'] = meta;
    if (self != null) json['links'] = {'self': self};
    return json;
  }
}
