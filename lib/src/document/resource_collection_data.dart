import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_object.dart';

/// Represents a resource collection or a collection of related resources of a to-many relationship
class ResourceCollectionData extends PrimaryData {
  final collection = <ResourceObject>[];

  ResourceCollectionData(Iterable<ResourceObject> collection,
      {Iterable<ResourceObject> included, Map<String, Link> links = const {}})
      : super(included: included, links: links) {
    this.collection.addAll(collection);
  }

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
    throw DecodingException(
        'Can not decode ResourceObjectCollection from $json');
  }

  /// The link to the last page. May be null.
  Link get last => links['last'];

  /// The link to the first page. May be null.
  Link get first => links['first'];

  /// The link to the next page. May be null.
  Link get next => links['next'];

  /// The link to the prev page. May be null.
  Link get prev => links['prev'];

  List<Resource> unwrap() => collection.map((_) => _.unwrap()).toList();

  @override
  Map<String, Object> toJson() => {
        ...super.toJson(),
        ...{'data': collection},
      };
}
