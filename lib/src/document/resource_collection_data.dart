import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource_object.dart';

/// Represents a resource collection or a collection of related resources of a to-many relationship
class ResourceCollectionData extends PrimaryData {
  final collection = <ResourceObject>[];
  final Pagination pagination;

  ResourceCollectionData(Iterable<ResourceObject> collection,
      {Link self,
      Iterable<ResourceObject> included,
      this.pagination = const Pagination.empty()})
      : super(self: self, included: included) {
    this.collection.addAll(collection);
  }

  @override
  Map<String, Object> toJson() {
    final json = super.toJson()..['data'] = collection;
    if (included != null && included.isNotEmpty) {
      json['included'] = included;
    }

    final links = toLinks()..addAll(pagination.toLinks());
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }

  @override
  bool identifies(ResourceObject resourceObject) =>
      collection.any((_) => _.identifies(resourceObject));
}
