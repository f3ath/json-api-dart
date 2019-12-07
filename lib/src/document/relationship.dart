import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/navigation.dart';
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
  Link get related => links['related'];

  Relationship(
      {Link related,
      Link self,
      Iterable<ResourceObject> included,
      Map<String, Link> links = const {}})
      : super(self: self, included: included, links: {
          ...links,
          if (related != null) ...{'related': related}
        });

  /// Reconstructs a JSON:API Document or the `relationship` member of a Resource object.
  static Relationship fromJson(Object json) {
    if (json is Map) {
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data == null || data is Map) {
          return ToOne.fromJson(json);
        }
        if (data is List) {
          return ToMany.fromJson(json);
        }
      }
      return Relationship(links: Link.fromJsonMap(json['links']));
    }
    throw DecodingException('Can not decode Relationship from $json');
  }

  /// Parses the `relationships` member of a Resource Object
  static Map<String, Relationship> fromJsonMap(Object json) {
    if (json == null) return {};
    if (json is Map) {
      return json
          .map((k, v) => MapEntry(k.toString(), Relationship.fromJson(v)));
    }
    throw DecodingException('Can not decode Relationship map from $json');
  }

  /// Top-level JSON object
  Map<String, Object> toJson() {
    final json = super.toJson();
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }
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
      {Link self,
      Link related,
      Iterable<ResourceObject> included,
      Map<String, Link> links = const {}})
      : super(self: self, related: related, included: included, links: links);

  ToOne.empty({Link self, Link related})
      : linkage = null,
        super(self: self, related: related);

  static ToOne fromJson(Object json) {
    if (json is Map && json.containsKey('data')) {
      return ToOne(nullable(IdentifierObject.fromJson)(json['data']),
          links: Link.fromJsonMap(json['links']),
          included: nullable(ResourceObject.fromJsonList)(json['included']));
    }
    throw DecodingException('Can not decode ToOne from $json');
  }

  Map<String, Object> toJson() => super.toJson()..['data'] = linkage;

  /// Converts to [Identifier].
  /// For empty relationships returns null.
  Identifier unwrap() => linkage?.unwrap();
}

/// Relationship to-many
class ToMany extends Relationship {
  /// Resource Linkage
  ///
  /// Can be empty for empty relationships
  ///
  /// More on this: https://jsonapi.org/format/#document-resource-object-linkage
  final linkage = <IdentifierObject>[];

  final Navigation navigation;

  ToMany(Iterable<IdentifierObject> linkage,
      {Link self,
      Link related,
      Iterable<ResourceObject> included,
      this.navigation = const Navigation(),
      Map<String, Link> links = const {}})
      : super(self: self, related: related, included: included, links: links) {
    this.linkage.addAll(linkage);
  }

  static ToMany fromJson(Object json) {
    if (json is Map) {
      final links = Link.fromJsonMap(json['links']);
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data is List) {
          return ToMany(
            data.map(IdentifierObject.fromJson),
            links: links,
            navigation: Navigation.fromLinks(links),
          );
        }
      }
    }
    throw DecodingException('Can not decode ToMany from $json');
  }

  Map<String, Object> toJson() => {
        ...super.toJson(),
        'data': linkage,
      };

  /// Converts to List<[Identifier]>.
  /// For empty relationships returns an empty List.
  List<Identifier> get identifiers => linkage.map((_) => _.unwrap()).toList();
}
