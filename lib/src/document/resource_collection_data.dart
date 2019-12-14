import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/navigation.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_object.dart';

/// Represents a resource collection or a collection of related resources of a to-many relationship
class ResourceCollectionData extends PrimaryData {
  final collection = <ResourceObject>[];

  ResourceCollectionData(Iterable<ResourceObject> collection,
      {Link self,
      Iterable<ResourceObject> included,
      Navigation navigation = const Navigation(),
      Map<String, Link> links = const {}})
      : super(
            self: self,
            included: included,
            links: {...links, ...navigation.links}) {
    this.collection.addAll(collection);
  }

  static ResourceCollectionData fromJson(Object json) {
    if (json is Map) {
      final data = json['data'];
      if (data is List) {
        return ResourceCollectionData(data.map(ResourceObject.fromJson),
            links: Link.mapFromJson(json['links'] ?? {}),
            included: ResourceObject.fromJsonList(json['included']));
      }
    }
    throw DecodingException(
        'Can not decode ResourceObjectCollection from $json');
  }

  Navigation get navigation => Navigation.fromLinks(links);

  List<Resource> unwrap() => collection.map((_) => _.unwrap()).toList();

  @override
  Map<String, Object> toJson() => {
        ...super.toJson(),
        ...{'data': collection},
      };
}
