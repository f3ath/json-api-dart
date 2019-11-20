import 'package:json_api/json_api.dart';
import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/navigation.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource_object.dart';
import 'package:json_api/src/nullable.dart';

/// Represents a resource collection or a collection of related resources of a to-many relationship
class ResourceCollectionData extends PrimaryData {
  final collection = <ResourceObject>[];
  final Navigation navigation;

  ResourceCollectionData(Iterable<ResourceObject> collection,
      {Link self,
      Iterable<ResourceObject> included,
      this.navigation = const Navigation()})
      : super(self: self, included: included) {
    this.collection.addAll(collection);
  }

  static ResourceCollectionData fromJson(Object json) {
    if (json is Map) {
      final links = Link.fromJsonMap(json['links']);
      final data = json['data'];
      if (data is List) {
        return ResourceCollectionData(data.map(ResourceObject.fromJson),
            self: links['self'],
            navigation: Navigation.fromLinks(links),
            included: nullable(ResourceObject.fromJsonList)(json['included']));
      }
    }
    throw DecodingException(
        'Can not decode ResourceObjectCollection from $json');
  }

  Map<String, Link> get links => {...super.links, ...navigation.links};

  List<Resource> unwrap() => collection.map((_) => _.unwrap()).toList();

  @override
  Map<String, Object> toJson() {
    final json = super.toJson()..['data'] = collection;
    if (included != null && included.isNotEmpty) {
      json['included'] = included;
    }
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }
}
