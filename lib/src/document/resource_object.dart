import 'package:json_api/document.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/nullable.dart';

/// [ResourceObject] is a JSON representation of a [Resource].
///
/// In a JSON:API Document it can be the value of the `data` member (a `data`
/// member element in case of a collection) or a member of the `included`
/// resource collection.
///
/// More on this: https://jsonapi.org/format/#document-resource-objects
class ResourceObject {
  final String type;
  final String id;

  final Map<String, Object> attributes;
  final Map<String, Relationship> relationships;
  final Map<String, Object> meta;

  /// Read-only `links` object. May be empty.
  final Map<String, Link> links;

  ResourceObject(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Relationship> relationships,
      Map<String, Object> meta,
      Map<String, Link> links})
      : links = (links == null) ? null : Map.unmodifiable(links),
        attributes = (attributes == null) ? null : Map.unmodifiable(attributes),
        meta = (meta == null) ? null : Map.unmodifiable(meta),
        relationships =
            (relationships == null) ? null : Map.unmodifiable(relationships);

  Link get self => (links ?? {})['self'];

  /// Reconstructs the `data` member of a JSON:API Document.
  /// If [json] is null, returns null.
  static ResourceObject fromJson(Object json) {
    if (json is Map) {
      final relationships = json['relationships'];
      final attributes = json['attributes'];
      if ((relationships == null || relationships is Map) &&
          (attributes == null || attributes is Map)) {
        return ResourceObject(json['type'], json['id'],
            attributes: attributes,
            relationships: nullable(Relationship.mapFromJson)(relationships),
            links: Link.mapFromJson(json['links'] ?? {}),
            meta: json['meta']);
      }
    }
    throw DocumentException('A JSON:API resource must be a JSON object');
  }

  static List<ResourceObject> fromJsonList(Iterable<Object> json) =>
      json.map(fromJson).toList();

  /// Returns the JSON object to be used in the `data` or `included` members
  /// of a JSON:API Document
  Map<String, Object> toJson() => {
        'type': type,
        if (id != null) ...{'id': id},
        if (meta != null) ...{'meta': meta},
        if (attributes != null) ...{'attributes': attributes},
        if (relationships != null) ...{'relationships': relationships},
        if (links != null) ...{'links': links},
      };

  /// Extracts the [Resource] if possible. The standard allows relationships
  /// without `data` member. In this case the original [Resource] can not be
  /// recovered and this method will throw a [StateError].
  Resource unwrap() {
    final toOne = <String, Identifier>{};
    final toMany = <String, List<Identifier>>{};
    final incomplete = <String, Relationship>{};
    (relationships ?? {}).forEach((name, rel) {
      if (rel is ToOne) {
        toOne[name] = rel.unwrap();
      } else if (rel is ToMany) {
        toMany[name] = rel.identifiers;
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
