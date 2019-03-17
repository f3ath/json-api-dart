import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_json.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/nullable.dart';

/// [ResourceJson] is a JSON representation of a [Resource].
///
/// It carries all JSON-related logic and the Meta-data.
/// In a JSON:API Document it can be the value of the `data` member (a `data`
/// member element in case of a collection) or a member of the `included`
/// resource collection.
///
/// More on this: https://jsonapi.org/format/#document-resource-objects
class ResourceJson {
  final String type;
  final String id;
  final attributes = <String, Object>{};
  final relationships = <String, Relationship>{};

  ResourceJson(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Relationship> relationships}) {
    this.attributes.addAll(attributes ?? {});
    this.relationships.addAll(relationships ?? {});
  }

  /// Parses the `data` member of a JSON:API Document
  static ResourceJson parse(Object json) {
    final mapOrNull = (_) => _ == null || _ is Map;
    if (json is Map) {
      final relationships = json['relationships'];
      final attributes = json['attributes'];

      if (mapOrNull(relationships) && mapOrNull(attributes)) {
        return ResourceJson(json['type'], json['id'],
            attributes: attributes,
            relationships: Relationship.parseRelationships(relationships));
      }
    }
    throw 'Can not parse ResourceObject from $json';
  }

  static ResourceJson fromResource(Resource resource) {
    final relationships = <String, Relationship>{}
      ..addAll(resource.toOne.map((k, v) =>
          MapEntry(k, ToOne(nullable(IdentifierJson.fromIdentifier)(v)))))
      ..addAll(resource.toMany.map((k, v) =>
          MapEntry(k, ToMany(v.map(IdentifierJson.fromIdentifier)))));

    return ResourceJson(resource.type, resource.id,
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
class ResourceData extends PrimaryData {
  final ResourceJson resourceObject;

  ResourceData(this.resourceObject, {Link self}) : super(self: self);

  /// Parse the document
  static ResourceData parseDocument(Object json) {
    if (json is Map) {
      final links = Link.parseLinks(json['links']);
      final data = ResourceJson.parse(json['data']);
      return ResourceData(data, self: links['self']);
    }
    throw 'Can not parse SingleResourceObject from $json';
  }

  @override
  Map<String, Object> toJson() {
    final json = <String, Object>{'data': resourceObject};
    final links = toLinks();
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }

  Resource toResource() => resourceObject.toResource();
}

/// Represents a resource collection or a collection of related resources of a to-many relationship
class ResourceCollectionData extends PrimaryData {
  final resourceObjects = <ResourceJson>[];
  final Pagination pagination;

  ResourceCollectionData(Iterable<ResourceJson> collection,
      {Link self, this.pagination = const Pagination.empty()})
      : super(self: self) {
    this.resourceObjects.addAll(collection);
  }

  /// Parse the document
  static ResourceCollectionData parseDocument(Object json) {
    if (json is Map) {
      final links = Link.parseLinks(json['links']);
      final data = json['data'];
      if (data is List) {
        return ResourceCollectionData(data.map(ResourceJson.parse),
            self: links['self'], pagination: Pagination.fromLinks(links));
      }
    }
    throw 'Can not parse ResourceObjectCollection from $json';
  }

  @override
  Map<String, Object> toJson() {
    final json = <String, Object>{'data': resourceObjects};
    final links = toLinks()..addAll(pagination.toLinks());
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }
}
