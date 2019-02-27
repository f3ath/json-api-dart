import 'package:json_api/src/transport/document.dart';
import 'package:json_api/src/transport/link.dart';
import 'package:json_api/src/transport/resource_object.dart';

class ResourceDocument implements Document {
  final ResourceObject resourceObject;
  final List<ResourceObject> included;
  final Link self;

  ResourceDocument(this.resourceObject,
      {List<ResourceObject> included, this.self})
      : included = List.unmodifiable(included ?? []);

  toJson() {
    final json = <String, Object>{'data': resourceObject};

    final links = {'self': self}..removeWhere((k, v) => v == null);
    if (links.isNotEmpty) {
      json['links'] = links;
    }
    if (included.isNotEmpty) json['included'] = included.toList();
    return json;
  }

  static ResourceDocument fromJson(Object json) {
    if (json is Map) {
      final data = json['data'];
      if (data is Map) {
        return ResourceDocument(ResourceObject.fromJson(data));
      }
      if (data == null) {
        return ResourceDocument(null);
      }
    }
    throw 'Can not parse ResourceDocument from $json';
  }
}
