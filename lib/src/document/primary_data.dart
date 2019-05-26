import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_object.dart';

/// The top-level Primary Data. This is the essentials of the JSON:API Document.
///
/// [PrimaryData] may be considered a Document itself with two limitations:
/// - it always has the `data` key (could have `null` value for empty to-one relationships)
/// - it can not have `meta` and `jsonapi` keys
abstract class PrimaryData {
  /// In Compound document this member contains the included resources
  final List<ResourceObject> included;

  /// For Compound document data returns true if the data is fully linked
  ///
  /// Details: http://jsonapi.org/format/#document-compound-documents
  get isFullyLinked =>
      !isCompound ||
      included.every((resource) =>
          identifies(resource) ||
          included
              .any((other) => other != resource && other.identifies(resource)));

  final Link self;

  PrimaryData({this.self, Iterable<ResourceObject> included})
      : this.included =
            (included == null || included.isEmpty) ? null : List.from(included);

  /// Documents with included resources are called compound
  ///
  /// Details: http://jsonapi.org/format/#document-compound-documents
  bool get isCompound => included != null && included.isNotEmpty;

  /// The top-level `links` object
  Map<String, Link> toLinks() => self == null ? {} : {'self': self};

  /// Top-level JSON object
  Map<String, Object> toJson() =>
      (included != null && included.isNotEmpty) ? {'included': included} : {};

  bool identifies(ResourceObject resourceObject);
}
