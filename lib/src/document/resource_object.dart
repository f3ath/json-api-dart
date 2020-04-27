import 'package:json_api/document.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/links.dart';
import 'package:json_api/src/document/meta.dart';
import 'package:json_api/src/document/relationship_object.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/nullable.dart';

/// [ResourceObject] is a JSON representation of a [Resource].
///
/// In a JSON:API Document it can be the value of the `data` member (a `data`
/// member element in case of a collection) or a member of the `included`
/// resource collection.
///
/// More on this: https://jsonapi.org/format/#document-resource-objects
class ResourceObject with Meta, Links {
  ResourceObject(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, RelationshipObject> relationships,
      Map<String, Object> meta,
      Map<String, Link> links})
      : attributes = Map.unmodifiable(attributes ?? const {}),
        relationships = Map.unmodifiable(relationships ?? const {}) {
    this.meta.addAll(meta ?? {});
    this.links.addAll(links ?? {});
  }

  static ResourceObject fromResource(Resource resource) =>
      ResourceObject(resource.type, resource.id,
          attributes: resource.attributes,
          relationships: {
            ...resource.toOne.map((k, v) => MapEntry(k, ToOneObject(v))),
            ...resource.toMany.map((k, v) => MapEntry(k, ToManyObject(v)))
          });

  /// Reconstructs the `data` member of a JSON:API Document.
  static ResourceObject fromJson(Object json) {
    if (json is Map) {
      final relationships = json['relationships'];
      final attributes = json['attributes'];
      final type = json['type'];
      if ((relationships == null || relationships is Map) &&
          (attributes == null || attributes is Map) &&
          type is String &&
          type.isNotEmpty) {
        return ResourceObject(json['type'], json['id'],
            attributes: attributes,
            relationships:
                nullable(RelationshipObject.mapFromJson)(relationships),
            links: Link.mapFromJson(json['links'] ?? {}),
            meta: json['meta']);
      }
      throw DocumentException('Invalid JSON:API resource object');
    }
    throw DocumentException('A JSON:API resource must be a JSON object');
  }

  final String type;
  final String id;
  final Map<String, Object> attributes;
  final Map<String, RelationshipObject> relationships;

  Link get self => links['self'];

  /// Returns the JSON object to be used in the `data` or `included` members
  /// of a JSON:API Document
  Map<String, Object> toJson() => {
        'type': type,
        if (id != null) 'id': id,
        if (meta.isNotEmpty) 'meta': meta,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (links.isNotEmpty) 'links': links,
      };

  /// Extracts the [Resource] if possible. The standard allows relationships
  /// without `data` member. In this case the original [Resource] can not be
  /// recovered and this method will throw a [StateError].
  ///
  /// Example of missing `data`: https://discuss.jsonapi.org/t/relationships-data-node/223
  Resource unwrap() {
    final toOne = <String, Identifier>{};
    final toMany = <String, List<Identifier>>{};
    final incomplete = <String, RelationshipObject>{};
    relationships.forEach((name, rel) {
      if (rel is ToOneObject) {
        toOne[name] = rel.linkage;
      } else if (rel is ToManyObject) {
        toMany[name] = rel.linkage;
      } else {
        incomplete[name] = rel;
      }
    });

    if (incomplete.isNotEmpty) {
      throw StateError('Can not convert to resource'
          ' due to incomplete relationship: ${incomplete.keys}');
    }

    return Resource(type, id,
        attributes: attributes, toOne: toOne, toMany: toMany);
  }
}
