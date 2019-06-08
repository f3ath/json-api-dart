import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/document/primary_data.dart';
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
class Relationship extends PrimaryData {
  final Link related;

  Map<String, Link> get links => {
        ...super.links,
        if (related != null) ...{'related': related},
      };

  Relationship({this.related, Link self, Iterable<ResourceObject> included})
      : super(self: self, included: included);

  /// Decodes a JSON:API Document or the `relationship` member of a Resource object.
  static Relationship decodeJson(Object json) {
    if (json is Map) {
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data == null || data is Map) {
          return ToOne.decodeJson(json);
        }
        if (data is List) {
          return ToMany.decodeJson(json);
        }
      } else {
        final links = Link.mapFromJson(json['links']);
        return Relationship(self: links['self'], related: links['related']);
      }
    }
    throw DecodingException('Can not decode Relationship from $json');
  }

  /// Parses the `relationships` member of a Resource Object
  static Map<String, Relationship> mapFromJson(Object json) {
    if (json == null) return {};
    if (json is Map) {
      return json
          .map((k, v) => MapEntry(k.toString(), Relationship.decodeJson(v)));
    }
    throw DecodingException('Can not decode Relationship map from $json');
  }

  /// Top-level JSON object
  Map<String, Object> toJson() {
    final json = super.toJson();
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }

  bool identifies(ResourceObject resourceObject) => false;
}

/// Relationship to-one
class ToOne extends Relationship {
  /// Resource Linkage
  ///
  /// Can be null for empty relationships
  ///
  /// More on this: https://jsonapi.org/format/#document-resource-object-linkage
  final IdentifierObject linkage;

  ToOne(this.linkage,
      {Link self, Link related, Iterable<ResourceObject> included})
      : super(self: self, related: related, included: included);

  ToOne.empty({Link self, Link related})
      : linkage = null,
        super(self: self, related: related);

  static ToOne fromIdentifier(Identifier identifier) =>
      ToOne(nullable(IdentifierObject.fromIdentifier)(identifier));

  static ToOne decodeJson(Object json) {
    if (json is Map) {
      final links = Link.mapFromJson(json['links']);
      final included = json['included'];
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data == null) {
          return ToOne(null,
              self: links['self'],
              related: links['related'],
              included: included == null
                  ? null
                  : ResourceObject.listFromJson(included));
        }
        if (data is Map) {
          return ToOne(IdentifierObject.decodeJson(data),
              self: links['self'],
              related: links['related'],
              included: included == null
                  ? null
                  : ResourceObject.listFromJson(included));
        }
      }
    }
    throw DecodingException('Can not decode ToOne from $json');
  }

  Map<String, Object> toJson() => super.toJson()..['data'] = linkage;

  /// Converts to [Identifier].
  /// For empty relationships return null.
  Identifier toIdentifier() => linkage?.toIdentifier();

  @override
  bool identifies(ResourceObject resourceObject) =>
      resourceObject.toResource().toIdentifier().equals(toIdentifier());
}

/// Relationship to-many
class ToMany extends Relationship {
  /// Resource Linkage
  ///
  /// Can be empty for empty relationships
  ///
  /// More on this: https://jsonapi.org/format/#document-resource-object-linkage
  final linkage = <IdentifierObject>[];

  final Pagination pagination;

  ToMany(Iterable<IdentifierObject> linkage,
      {Link self,
      Link related,
      Iterable<ResourceObject> included,
      this.pagination = const Pagination.empty()})
      : super(self: self, related: related, included: included) {
    this.linkage.addAll(linkage);
  }

  static ToMany decodeJson(Object json) {
    if (json is Map) {
      final links = Link.mapFromJson(json['links']);

      if (json.containsKey('data')) {
        final data = json['data'];
        if (data is List) {
          return ToMany(
            data.map(IdentifierObject.decodeJson),
            self: links['self'],
            related: links['related'],
            pagination: Pagination.fromLinks(links),
          );
        }
      }
    }
    throw DecodingException('Can not decode ToMany from $json');
  }

  Map<String, Object> toJson() => super.toJson()..['data'] = linkage;

  /// Converts to List<[Identifier]>.
  /// For empty relationships returns an empty List.
  List<Identifier> toIdentifiers() =>
      linkage.map((_) => _.toIdentifier()).toList();

  @override
  bool identifies(ResourceObject resourceObject) =>
      toIdentifiers().any(resourceObject.toResource().toIdentifier().equals);
}
