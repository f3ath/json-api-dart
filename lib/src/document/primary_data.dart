import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_object.dart';

/// The top-level Primary Data. This is the essentials of the JSON:API Document.
///
/// [PrimaryData] may be considered a Document itself with two limitations:
///
/// - it always has the `data` key (could have `null` value for empty to-one relationships)
///
/// - it can not have `meta` and `jsonapi` keys
abstract class PrimaryData {
  final Link self;

  /// For Compound Documents this member contains the included resources
  final included = <ResourceObject>[];

  PrimaryData({this.self});

  /// The top-level `links` object
  Map<String, Link> toLinks() => self == null ? {} : {'self': self};

  /// Top-level JSON object
  Map<String, Object> toJson();
}
