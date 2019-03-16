import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/nullable.dart';

/// ResourceObject is a JSON representation of a [Resource]
/// It carries all JSON-related logic and the Meta-data.
class ResourceObject {
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

  static ResourceObject parseData(Object json) {
    final mapOrNull = (_) => _ == null || _ is Map;
    if (json is Map) {
      final relationships = json['relationships'];
      final attributes = json['attributes'];

      if (mapOrNull(relationships) && mapOrNull(attributes)) {
        return ResourceObject(json['type'], json['id'],
            attributes: attributes,
            relationships: Relationship.parseRelationships(relationships));
      }
    }
    throw 'Can not parse ResourceObject from $json';
  }

  static ResourceObject fromResource(Resource resource) {
    final relationships = <String, Relationship>{}
      ..addAll(resource.toOne.map(
          (k, v) => MapEntry(k, ToOne(nullable(IdentifierObject.fromIdentifier)(v)))))
      ..addAll(resource.toMany.map((k, v) =>
          MapEntry(k, ToMany(v.map(IdentifierObject.fromIdentifier)))));

    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes, relationships: relationships);
  }

  Map<String, Object> toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (attributes.isNotEmpty) {
      json['attributes'] = attributes;
    }
    if (relationships.isNotEmpty) {
      json['relationships'] = relationships;
    }
    return json;
  }

  /// Converts to [Resource] if possible
  Resource toResource() {
    final toOne = <String, Identifier>{};
    final toMany = <String, List<Identifier>>{};
    final incomplete = <String, Relationship>{};
    relationships.forEach((name, rel) {
      if (rel is ToOne) {
        toOne[name] = rel.toIdentifier();
      } else if (rel is ToMany) {
        toMany[name] = rel.identifiers.toList();
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

/// Represents a single resource or a single related resource of a to-one relationship\\\\\\\\
class SingleResourceObject extends PrimaryData {
  final ResourceObject resourceObject;

  SingleResourceObject(this.resourceObject, {Link self}) : super(self: self);

  /// Parse the document
  static SingleResourceObject parseDocument(Object json) {
    if (json is Map) {
      final links = Link.parseLinks(json['links']);
      final data = ResourceObject.parseData(json['data']);
      return SingleResourceObject(data, self: links['self']);
    }
    throw 'Can not parse SingleResourceObject from $json';
  }

  @override
  Map<String, Object> toJson() {
    final json = <String, Object>{'data': resourceObject};
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }

  Resource toResource() => resourceObject.toResource();
}

/// Represents a resource collection or a collection of related resources of a to-many relationship
class ResourceObjectCollection extends PrimaryData {
  final resourceObjects = <ResourceObject>[];
  final Pagination pagination;

  ResourceObjectCollection(Iterable<ResourceObject> collection,
      {Link self, this.pagination = const Pagination.empty()})
      : super(self: self) {
    this.resourceObjects.addAll(collection);
  }

  /// Parse the document
  static ResourceObjectCollection parseDocument(Object json) {
    if (json is Map) {
      final links = Link.parseLinks(json['links']);
      final data = json['data'];
      if (data is List) {
        return ResourceObjectCollection(data.map(ResourceObject.parseData),
            self: links['self'], pagination: Pagination.fromLinks(links));
      }
    }
    throw 'Can not parse ResourceObjectCollection from $json';
  }

  @override
  Map<String, Object> toJson() {
    final json = <String, Object>{'data': resourceObjects};
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }
}
