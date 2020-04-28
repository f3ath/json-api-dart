import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/meta.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_object.dart';
import 'package:json_api/src/nullable.dart';

/// The Relationship represents the references between the resources.
///
/// A Relationship can be a JSON:API Document itself when
/// requested separately as described here https://jsonapi.org/format/#fetching-relationships.
///
/// It can also be a part of [ResourceObject].relationships map.
///
/// More on this: https://jsonapi.org/format/#document-resource-object-relationships
class RelationshipObject extends PrimaryData with Meta {
  RelationshipObject({Map<String, Link> links}) : super(links: links);

  /// Reconstructs a JSON:API Document or the `relationship` member of a Resource object.
  static RelationshipObject fromJson(Object json) {
    if (json is Map) {
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data == null || data is Map) {
          return ToOneObject.fromJson(json);
        }
        if (data is List) {
          return ToManyObject.fromJson(json);
        }
      }
      return RelationshipObject(
          links: nullable(Link.mapFromJson)(json['links']));
    }
    throw DocumentException(
        'A JSON:API relationship object must be a JSON object');
  }

  /// Parses the `relationships` member of a Resource Object
  static Map<String, RelationshipObject> mapFromJson(Object json) {
    if (json is Map) {
      return json.map(
          (k, v) => MapEntry(k.toString(), RelationshipObject.fromJson(v)));
    }
    throw DocumentException("The 'relationships' member must be a JSON object");
  }

  @override
  Map<String, Object> toJson() =>
      {...super.toJson(), if (meta.isNotEmpty) 'meta': meta};
}

/// Relationship to-one
class ToOneObject extends RelationshipObject {
  ToOneObject(this.linkage, {Map<String, Link> links}) : super(links: links);

  ToOneObject.empty({Link self, Map<String, Link> links})
      : linkage = null,
        super(links: links);

  static ToOneObject fromIdentifier(Identifier identifier) =>
      ToOneObject(identifier);

  static ToOneObject fromJson(Object json) {
    if (json is Map && json.containsKey('data')) {
      return ToOneObject(nullable(Identifier.fromJson)(json['data']),
          links: nullable(Link.mapFromJson)(json['links']));
    }
    throw DocumentException(
        "A to-one relationship must be a JSON object and contain the 'data' member");
  }

  /// Resource Linkage
  ///
  /// Can be null for empty relationships
  ///
  /// More on this: https://jsonapi.org/format/#document-resource-object-linkage
  final Identifier linkage;

  ToOne unwrap() => ToOne.fromNullable(linkage);

  @override
  Map<String, Object> toJson() => {
        ...super.toJson(),
        'data': linkage,
      };
}

/// Relationship to-many
class ToManyObject extends RelationshipObject {
  ToManyObject(Iterable<Identifier> linkage, {Map<String, Link> links})
      : linkage = List.unmodifiable(linkage),
        super(links: links);

  static ToManyObject fromIdentifiers(Iterable<Identifier> identifiers) =>
      ToManyObject(identifiers);

  static ToManyObject fromJson(Object json) {
    if (json is Map && json.containsKey('data')) {
      final data = json['data'];
      if (data is List) {
        return ToManyObject(
          data.map(Identifier.fromJson),
          links: nullable(Link.mapFromJson)(json['links']),
        );
      }
    }
    throw DocumentException(
        "A to-many relationship must be a JSON object and contain the 'data' member");
  }

  /// Resource Linkage
  ///
  /// Can be empty for empty relationships
  ///
  /// More on this: https://jsonapi.org/format/#document-resource-object-linkage
  final List<Identifier> linkage;

  @override
  Map<String, Object> toJson() => {
        ...super.toJson(),
        'data': linkage,
      };
}
