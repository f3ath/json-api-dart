import 'package:json_api/resource.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/transport/identifier_envelope.dart';
import 'package:json_api/src/transport/link.dart';
import 'package:json_api/src/transport/relationship.dart';

/// Resource object
class ResourceEnvelope {
  final String type;
  final String id;
  final Link self;
  final Map<String, Object> attributes;
  final Map<String, Object> meta;
  final Map<String, Relationship> relationships;

  ResourceEnvelope(this.type, this.id,
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
      if (rel is ToOne) toOne[name] = rel.identifier;
      if (rel is ToMany) toMany[name] = rel.identifiers;
    });
    return Resource(type, id,
        attributes: attributes, toMany: toMany, toOne: toOne);
  }

  static ResourceEnvelope enclose(Resource r) {
    final toOne = r.toOne.map((name, v) =>
        MapEntry(name, ToOne(nullable(IdentifierEnvelope.fromIdentifier)(v))));

    final toMany = r.toMany.map((name, v) => MapEntry(
        name,
        ToMany(
          v.map(nullable(IdentifierEnvelope.fromIdentifier)).toList(),
        )));

    return ResourceEnvelope(r.type, r.id,
        attributes: r.attributes,
        relationships: <String, Relationship>{}..addAll(toOne)..addAll(toMany));
  }

  static ResourceEnvelope fromJson(Object json) {
    if (json is Map) {
      final links = Link.parseMap(json['links'] ?? {});

      return ResourceEnvelope(
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
