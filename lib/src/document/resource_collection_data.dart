import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource_object.dart';

/// Represents a resource collection or a collection of related resources of a to-many relationship
class ResourceCollectionData extends PrimaryData {
  final collection = <ResourceObject>[];
  final Pagination pagination;

  /// For Compound Documents this member contains the included resources
  final List<ResourceObject> included;

  ResourceCollectionData(Iterable<ResourceObject> collection,
      {Link self,
      Iterable<ResourceObject> included,
      this.pagination = const Pagination.empty()})
      : this.included =
            (included == null || included.isEmpty ? null : List.from(included)),
        super(self: self) {
    this.collection.addAll(collection);
  }

  @override
  Map<String, Object> toJson() {
    final json = <String, Object>{'data': collection};
    if (included != null && included.isNotEmpty) {
      json['included'] = included;
    }

    final links = toLinks()..addAll(pagination.toLinks());
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }
}
