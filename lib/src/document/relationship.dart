import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/document/primary_data.dart';

/// Incomplete relationship
class Relationship extends PrimaryData {
  final Link related;

  Relationship({this.related, Link self}) : super(self: self);

  /// Parses a JSON:API Document or the `relationship` member of a Resource object.
  static Relationship parse(Object json) {
    if (json is Map) {
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data == null || data is Map) {
          return ToOne.parse(json);
        }
        if (data is List) {
          return ToMany.parse(json);
        }
      } else {
        final links = Link.parseLinks(json['links']);
        return Relationship(self: links['self'], related: links['related']);
      }
    }
    throw 'Can not parse Relationship from $json';
  }

  /// Parses the `relationships` member of a Resource Object
  static Map<String, Relationship> parseRelationships(Object json) {
    if (json == null) return {};
    if (json is Map) {
      return json.map((k, v) => MapEntry(k.toString(), Relationship.parse(v)));
    }
    throw 'Can not parse Relationship map from $json';
  }

  Map<String, Link> get links => related == null ? super.links : super.links
    ..['related'] = related;

  /// Top-level JSON object
  Map<String, Object> toJson() {
    final json = <String, Object>{};
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }
}

/// Relationship to-one
class ToOne extends Relationship {
  /// null if empty
  final IdentifierObject linkage;

  ToOne(this.linkage, {Link self, Link related})
      : super(self: self, related: related);

  ToOne.empty({Link self, Link related})
      : linkage = null,
        super(self: self, related: related);

  static ToOne parse(Object json) {
    if (json is Map) {
      final links = Link.parseLinks(json['links']);
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data == null) {
          return ToOne.empty(self: links['self'], related: links['related']);
        }
        if (data is Map) {
          return ToOne(IdentifierObject.parseData(data),
              self: links['self'], related: links['related']);
        }
      }
    }
    throw 'Can not parse ToOne from $json';
  }

  Map<String, Object> toJson() => super.toJson()..['data'] = linkage;

  /// Converts to [Identifier].
  /// For empty relationships return null.
  Identifier toIdentifier() => linkage?.toIdentifier();
}

/// Relationship to-many
class ToMany extends Relationship {
  final linkage = <IdentifierObject>[];
  final Pagination pagination;

  ToMany(Iterable<IdentifierObject> linkage,
      {Link self, Link related, this.pagination = const Pagination.empty()})
      : super(self: self, related: related) {
    this.linkage.addAll(linkage);
  }

  static ToMany parse(Object json) {
    if (json is Map) {
      final links = Link.parseLinks(json['links']);
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data is List) {
          return ToMany(data.map(IdentifierObject.parseData),
              self: links['self'], related: links['related']);
        }
      }
    }
    throw 'Can not parse ToMany from $json';
  }

  Map<String, Link> get links => super.links..addAll(pagination?.links ?? {});

  Map<String, Object> toJson() => super.toJson()..['data'] = linkage;

  /// Converts to List<[Identifier]>.
  /// For empty relationships returns an empty List.
  Iterable<Identifier> get identifiers => linkage.map((_) => _.toIdentifier());
}
