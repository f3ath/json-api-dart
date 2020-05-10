import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_object.dart';
import 'package:json_api/src/nullable.dart';

/// Represents a single resource or a single related resource of a to-one relationship
class ResourceData extends PrimaryData {
  ResourceData(this.resourceObject, {Map<String, Link> links})
      : super(links: links);

  static ResourceData fromResource(Resource resource) =>
      ResourceData(ResourceObject.fromResource(resource));

  static ResourceData fromJson(Object json) {
    if (json is Map) {
      return ResourceData(nullable(ResourceObject.fromJson)(json['data']),
          links: nullable(Link.mapFromJson)(json['links']));
    }
    throw DocumentException(
        "A JSON:API resource document must be a JSON object and contain the 'data' member");
  }

  final ResourceObject resourceObject;

  @override
  Map<String, Object> toJson() => {
        ...super.toJson(),
        'data': resourceObject?.toJson(),
      };

  Resource unwrap() => resourceObject?.unwrap();
}
