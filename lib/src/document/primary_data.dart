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
      : isCompound = included != null,
        included = List.unmodifiable(included ?? const []),
        links = Map.unmodifiable(links ?? const {});

  /// In a Compound document, this member contains the included resources.
  final List<ResourceObject> included;

  /// True for compound documents.
  final bool isCompound;

  /// The top-level `links` object. May be empty or null.
  final Map<String, Link> links;

  /// The `self` link. May be null.
  Link get self => links['self'];

  @override
  Map<String, Object> toJson() => {
        if (links.isNotEmpty) 'links': links,
        if (isCompound) 'included': included,
      };
}
