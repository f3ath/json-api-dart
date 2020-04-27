import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/links.dart';

/// The top-level Primary Data. This is the essentials of the JSON:API Document.
///
/// [PrimaryData] may be considered a Document itself with two limitations:
/// - it always has the `data` key (could be `null` for an empty to-one relationship)
/// - it can not have `meta` and `jsonapi` keys
abstract class PrimaryData with Links {
  PrimaryData({Map<String, Link> links}) {
    this.links.addAll(links ?? {});
  }

  Map<String, Object> toJson() => {
        if (links.isNotEmpty) 'links': links,
      };
}

typedef PrimaryDataDecoder<D extends PrimaryData> = D Function(Object json);
