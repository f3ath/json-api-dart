import 'package:json_api/src/document/link.dart';

/// The top-level Primary Data. This is the essentials of the JSON:API Document.
///
/// [PrimaryData] may be considered a Document itself with two limitations:
/// - it always has the `data` key (could be `null` for an empty to-one relationship)
/// - it can not have `meta` and `jsonapi` keys
abstract class PrimaryData {
  PrimaryData({Map<String, Link> links})
      : links = Map.unmodifiable(links ?? const {});

  /// The top-level `links` object. May be empty or null.
  final Map<String, Link> links;

  /// The `self` link. May be null.
  Link get self => links['self'];

  Map<String, Object> toJson() => {
        if (links.isNotEmpty) 'links': links,
      };
}

typedef PrimaryDataDecoder<D extends PrimaryData> = D Function(Object json);
