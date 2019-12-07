import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_object.dart';

/// Represents a single resource or a single related resource of a to-one relationship
class ResourceData extends PrimaryData {
  final ResourceObject resourceObject;

  ResourceData(this.resourceObject,
      {Link self,
      Iterable<ResourceObject> included,
      Map<String, Link> links = const {}})
      : super(self: self, included: included, links: links);

  static ResourceData fromJson(Object json) {
    if (json is Map) {
      final included = json['included'];
      final resources = <ResourceObject>[];
      if (included is List) {
        resources.addAll(included.map(ResourceObject.fromJson));
      }
      final data = ResourceObject.fromJson(json['data']);
      return ResourceData(data,
          links: Link.mapFromJson(json['links']),
          included: resources.isNotEmpty ? resources : null);
    }
    throw DecodingException('Can not decode SingleResourceObject from $json');
  }

  @override
  Map<String, Object> toJson() => {
        ...super.toJson(),
        'data': resourceObject,
      };

  Resource unwrap() => resourceObject.unwrap();
}
