import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_object.dart';

/// The top-level Primary Data. This is the essentials of the JSON:API Document.
///
/// [PrimaryData] may be considered a Document itself with two limitations:
/// - it always has the `data` key (could be `null` for an empty to-one relationship)
/// - it can not have `meta` and `jsonapi` keys
abstract class PrimaryData {
  /// In a Compound document this member contains the included resources
  final List<ResourceObject> included;

  final Map<String, Link> _links;

  PrimaryData(
      {Link self,
      Iterable<ResourceObject> included,
      Map<String, Link> links = const {}})
      : this.included = (included == null) ? null : List.from(included),
        _links = {
          ...links,
          if (self != null) ...{'self': self}
        };

  /// The `self` link. May be null.
  Link get self => _links['self'];

  /// The top-level `links` object. May be empty.
  Map<String, Link> get links => Map.unmodifiable(_links);

  /// Documents with included resources are called compound
  ///
  /// Details: http://jsonapi.org/format/#document-compound-documents
  bool get isCompound => included != null && included.isNotEmpty;

  /// Top-level JSON object
  Map<String, Object> toJson() =>
      (included != null) ? {'included': included} : {};
}
