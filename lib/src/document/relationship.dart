import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_json.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/document/primary_data.dart';

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

  Relationship({this.related, Link self}) : super(self: self);

  Map<String, Link> toLinks() => related == null
      ? super.toLinks()
      : (super.toLinks()..['related'] = related);

  /// Top-level JSON object
  Map<String, Object> toJson() {
    final json = <String, Object>{};
    final links = toLinks();
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
  final IdentifierJson linkage;

  ToOne(this.linkage, {Link self, Link related})
      : super(self: self, related: related);

  ToOne.empty({Link self, Link related})
      : linkage = null,
        super(self: self, related: related);

  Map<String, Object> toJson() => super.toJson()..['data'] = linkage;

  /// Converts to [Identifier].
  /// For empty relationships return null.
  Identifier toIdentifier() => linkage?.toIdentifier();
}

/// Relationship to-many
class ToMany extends Relationship {
  /// Resource Linkage
  ///
  /// Can be empty for empty relationships
  ///
  /// More on this: https://jsonapi.org/format/#document-resource-object-linkage
  final linkage = <IdentifierJson>[];

  final Pagination pagination;

  ToMany(Iterable<IdentifierJson> linkage,
      {Link self, Link related, this.pagination = const Pagination.empty()})
      : super(self: self, related: related) {
    this.linkage.addAll(linkage);
  }

  Map<String, Link> toLinks() => super.toLinks()..addAll(pagination.toLinks());

  Map<String, Object> toJson() => super.toJson()..['data'] = linkage;

  /// Converts to List<[Identifier]>.
  /// For empty relationships returns an empty List.
  Iterable<Identifier> toIdentifiers() => linkage.map((_) => _.toIdentifier());
}
