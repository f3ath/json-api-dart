import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_object.dart';
import 'package:json_api/src/nullable.dart';

/// Represents a single resource or a single related resource of a to-one relationship
class ResourceData extends PrimaryData {
  ResourceData(this.resourceObject,
      {Iterable<ResourceObject> included, Map<String, Link> links})
      : super(
            included: included, links: {...?resourceObject?.links, ...?links});

  static ResourceData fromResource(Resource resource) =>
      ResourceData(ResourceObject.fromResource(resource));

  static ResourceData fromJson(Object json) {
    if (json is Map) {
      Iterable<ResourceObject> resources;
      final included = json['included'];
      if (included is List) {
        resources = included.map(ResourceObject.fromJson);
      } else if (included != null) {
        throw DocumentException("The 'included' value must be a JSON array");
      }
      final data = nullable(ResourceObject.fromJson)(json['data']);
      return ResourceData(data,
          links: Link.mapFromJson(json['links'] ?? {}), included: resources);
    }
    throw DocumentException(
        "A JSON:API resource document must be a JSON object and contain the 'data' member");
  }

  final ResourceObject resourceObject;

  @override
  Map<String, Object> toJson() => {
        ...super.toJson(),
        'data': resourceObject.toJson(),
      };

  Resource unwrap() => resourceObject?.unwrap();
}
