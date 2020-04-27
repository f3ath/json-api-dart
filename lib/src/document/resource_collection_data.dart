import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_object.dart';

/// Represents a resource collection or a collection of related resources of a to-many relationship
class ResourceCollectionData extends PrimaryData {
  ResourceCollectionData(Iterable<ResourceObject> collection,
      {Map<String, Link> links})
      : collection = List.unmodifiable(collection ?? const []),
        super(links: links);

  static ResourceCollectionData fromJson(Object json) {
    if (json is Map) {
      final data = json['data'];
      if (data is List) {
        return ResourceCollectionData(data.map(ResourceObject.fromJson),
            links: Link.mapFromJson(json['links'] ?? {}));
      }
    }
    throw DocumentException(
        "A JSON:API resource collection document must be a JSON object with a JSON array in the 'data' member");
  }

  final List<ResourceObject> collection;

  /// Returns a list of resources contained in the collection
  List<Resource> unwrap() => collection.map((_) => _.unwrap()).toList();

  /// Returns a map of resources indexed by ids
  Map<String, Resource> unwrapToMap() =>
      Map<String, Resource>.fromIterable(unwrap(), key: (r) => r.id);

  @override
  Map<String, Object> toJson() => {
        ...super.toJson(),
        ...{'data': collection},
      };
}
