import 'package:json_api/src/document/json_encodable.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_object.dart';

/// The top-level Primary Data. This is the essentials of the JSON:API Document.
///
/// [PrimaryData] may be considered a Document itself with two limitations:
/// - it always has the `data` key (could be `null` for an empty to-one relationship)
/// - it can not have `meta` and `jsonapi` keys
abstract class PrimaryData implements JsonEncodable {
  PrimaryData({Iterable<ResourceObject> included, Map<String, Link> links})
      : included = (included == null) ? null : List.unmodifiable(included),
        links = (links == null) ? null : Map.unmodifiable(links);

  /// In a Compound document, this member contains the included resources.
  /// May be empty or null, this is to distinguish between two cases:
  /// - Inclusion was requested, but no resources were found (empty list)
  /// - Inclusion was not requested (null)
  final List<ResourceObject> included;

  /// The top-level `links` object. May be empty or null.
  final Map<String, Link> links;

  /// The `self` link. May be null.
  Link get self => (links ?? {})['self'];

  @override
  Map<String, Object> toJson() => {
        if (links != null) ...{'links': links},
        if (included != null) ...{'included': included}
      };
}
