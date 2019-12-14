import 'package:json_api/src/document/decoding_exception.dart';
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
  final Map<String, Link> _links;

  ResourceObject(this.type, this.id,
      {Link self,
      Map<String, Object> attributes,
      Map<String, Relationship> relationships,
      this.meta,
      Map<String, Link> links = const {}})
      : _links = {
          ...links,
          if (self != null) ...{'self': self}
        },
        attributes = attributes == null ? null : Map.from(attributes),
        relationships = relationships == null ? null : Map.from(relationships);

  Link get self => _links['self'];

  /// Read-only `links` object. May be empty.
  Map<String, Link> get links => Map.unmodifiable(_links);

  /// Reconstructs the `data` member of a JSON:API Document.
  /// If [json] is null, returns null.
  static ResourceObject fromJson(Object json) {
    if (json == null) return null;
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
    throw DecodingException('Can not decode ResourceObject from $json');
  }

  static List<ResourceObject> fromJsonList(Object json) {
    if (json == null) return null;
    if (json is List) return json.map(fromJson).toList();
    throw DecodingException(
        'Can not decode Iterable<ResourceObject> from $json');
  }

  /// Returns the JSON object to be used in the `data` or `included` members
  /// of a JSON:API Document
  Map<String, Object> toJson() => {
        'type': type,
        if (id != null) ...{'id': id},
        if (meta != null) ...{'meta': meta},
        if (attributes?.isNotEmpty == true) ...{'attributes': attributes},
        if (relationships?.isNotEmpty == true) ...{
          'relationships': relationships
        },
        if (_links.isNotEmpty) ...{'links': links},
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
