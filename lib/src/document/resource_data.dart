import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_object.dart';

/// Represents a single resource or a single related resource of a to-one relationship
class ResourceData extends PrimaryData {
  final ResourceObject resourceObject;

  ResourceData(this.resourceObject,
      {Link self, Iterable<ResourceObject> included})
      : super(self: self, included: included);

  static ResourceData decodeJson(Object json) {
    if (json is Map) {
      final links = Link.decodeJsonMap(json['links']);
      final included = json['included'];
      final resources = <ResourceObject>[];
      if (included is List) {
        resources.addAll(included.map(ResourceObject.decodeJson));
      }
      final data = ResourceObject.decodeJson(json['data']);
      return ResourceData(data,
          self: links['self'],
          included: resources.isNotEmpty ? resources : null);
    }
    throw DecodingException('Can not decode SingleResourceObject from $json');
  }

  @override
  Map<String, Object> toJson() {
    return {
      ...super.toJson(),
      'data': resourceObject,
      if (included != null && included.isNotEmpty) ...{'included': included},
      if (links.isNotEmpty) ...{'links': links},
    };
  }

  Resource toResource() => resourceObject.unwrap();

  bool identifies(ResourceObject r) => resourceObject.identifies(r);
}
