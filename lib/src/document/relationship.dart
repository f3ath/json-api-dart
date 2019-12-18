import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/link.dart';
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
  /// The "related" link. May be null.
  Link get related => (links ?? {})['related'];

  Relationship({Iterable<ResourceObject> included, Map<String, Link> links})
      : super(included: included, links: links);

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
      final links = json['links'];
      return Relationship(
          links: (links == null) ? null : Link.mapFromJson(links));
    }
    throw DecodingException('Can not decode Relationship from $json');
  }

  /// Parses the `relationships` member of a Resource Object
  static Map<String, Relationship> mapFromJson(Object json) {
    if (json is Map) {
      return json
          .map((k, v) => MapEntry(k.toString(), Relationship.fromJson(v)));
    }
    throw DecodingException('Can not decode Relationship map from $json');
  }

  /// Top-level JSON object
  Map<String, Object> toJson() => {
        ...super.toJson(),
        if (links != null) ...{'links': links}
      };
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
      {Iterable<ResourceObject> included, Map<String, Link> links})
      : super(included: included, links: links);

  ToOne.empty({Link self, Map<String, Link> links})
      : linkage = null,
        super(links: links);

  static ToOne fromJson(Object json) {
    if (json is Map && json.containsKey('data')) {
      final included = json['included'];
      final links = json['links'];
      return ToOne(nullable(IdentifierObject.fromJson)(json['data']),
          links: (links == null) ? null : Link.mapFromJson(links),
          included:
              included is List ? ResourceObject.fromJsonList(included) : null);
    }
    throw DecodingException('Can not decode ToOne from $json');
  }

  Map<String, Object> toJson() => {
        ...super.toJson(),
        ...{'data': linkage}
      };

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

  ToMany(Iterable<IdentifierObject> linkage,
      {Iterable<ResourceObject> included, Map<String, Link> links})
      : super(included: included, links: links) {
    this.linkage.addAll(linkage);
  }

  static ToMany fromJson(Object json) {
    if (json is Map && json.containsKey('data')) {
      final data = json['data'];
      if (data is List) {
        final links = json['links'];
        return ToMany(
          data.map(IdentifierObject.fromJson),
          links: (links == null) ? null : Link.mapFromJson(links),
        );
      }
    }
    throw DecodingException('Can not decode ToMany from $json');
  }

  Map<String, Object> toJson() => {
        ...super.toJson(),
        'data': linkage,
      };

  /// Converts to List<Identifier>.
  /// For empty relationships returns an empty List.
  List<Identifier> get identifiers => linkage.map((_) => _.unwrap()).toList();
}
