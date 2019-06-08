import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource_object.dart';

/// Represents a resource collection or a collection of related resources of a to-many relationship
class ResourceCollectionData extends PrimaryData {
  final collection = <ResourceObject>[];
  final Pagination pagination;

  Map<String, Link> get links => {...super.links, ...pagination.toLinks()};

  ResourceCollectionData(Iterable<ResourceObject> collection,
      {Link self,
      Iterable<ResourceObject> included,
      this.pagination = const Pagination.empty()})
      : super(self: self, included: included) {
    this.collection.addAll(collection);
  }

  static ResourceCollectionData decodeJson(Object json) {
    if (json is Map) {
      final links = Link.mapFromJson(json['links']);
      final included = json['included'];
      final data = json['data'];
      if (data is List) {
        return ResourceCollectionData(data.map(ResourceObject.decodeJson),
            self: links['self'],
            pagination: Pagination.fromLinks(links),
            included: included == null
                ? null
                : ResourceObject.listFromJson(included));
      }
    }
    throw DecodingException(
        'Can not decode ResourceObjectCollection from $json');
  }

  @override
  Map<String, Object> toJson() {
    final json = super.toJson()..['data'] = collection;
    if (included != null && included.isNotEmpty) {
      json['included'] = included;
    }
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }

  @override
  bool identifies(ResourceObject resourceObject) =>
      collection.any((_) => _.identifies(resourceObject));
}
