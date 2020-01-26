import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_object.dart';

/// Represents a resource collection or a collection of related resources of a to-many relationship
class ResourceCollectionData extends PrimaryData {
  final Iterable<ResourceObject> collection;

  ResourceCollectionData(Iterable<ResourceObject> collection,
      {Iterable<ResourceObject> included, Map<String, Link> links = const {}})
      : collection = List.unmodifiable(collection),
        super(included: included, links: links);

  static ResourceCollectionData fromJson(Object json) {
    if (json is Map) {
      final data = json['data'];
      if (data is List) {
        final included = json['included'];
        return ResourceCollectionData(data.map(ResourceObject.fromJson),
            links: Link.mapFromJson(json['links'] ?? {}),
            included: included is List
                ? ResourceObject.fromJsonList(included)
                : null);
      }
    }
    throw DocumentException(
        "A JSON:API resource collection document must be a JSON object with a JSON array in the 'data' member");
  }

  /// The link to the last page. May be null.
  Link get last => (links ?? {})['last'];

  /// The link to the first page. May be null.
  Link get first => (links ?? {})['first'];

  /// The link to the next page. May be null.
  Link get next => (links ?? {})['next'];

  /// The link to the prev page. May be null.
  Link get prev => (links ?? {})['prev'];

  /// Returns a list of resources contained in the collection
  Iterable<Resource> unwrap() => collection.map((_) => _.unwrap());

  /// Returns a map of resources indexed by ids
  Map<String, Resource> unwrapToMap() =>
      Map<String, Resource>.fromIterable(unwrap(), key: (r) => r.id);

  @override
  Map<String, Object> toJson() => {
        ...super.toJson(),
        ...{'data': collection},
      };
}
