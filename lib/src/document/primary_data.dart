import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_object.dart';

/// The top-level Primary Data. This is the essentials of the JSON:API Document.
///
/// [PrimaryData] may be considered a Document itself with two limitations:
/// - it always has the `data` key (could be `null` for an empty to-one relationship)
/// - it can not have `meta` and `jsonapi` keys
abstract class PrimaryData {
  /// In a Compound document this member contains the included resources.
  /// May be empty or null.
  final List<ResourceObject> included;

  /// The top-level `links` object. May be empty or null.
  final Map<String, Link> links;

  PrimaryData({Iterable<ResourceObject> included, Map<String, Link> links})
      : included = (included == null) ? null : List.unmodifiable(included),
        links = (links == null) ? null : Map.unmodifiable(links);

  /// The `self` link. May be null.
  Link get self => (links ?? {})['self'];

  /// Documents with included resources are called compound
  /// Details: http://jsonapi.org/format/#document-compound-documents
  bool get isCompound => included != null && included.isNotEmpty;

  /// Top-level JSON object
  Map<String, Object> toJson() => {
        if (links != null) ...{'links': links},
        if (included != null) ...{'included': included}
      };
}
