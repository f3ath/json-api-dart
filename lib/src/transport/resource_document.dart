import 'package:json_api/src/transport/document.dart';
import 'package:json_api/src/transport/link.dart';
import 'package:json_api/src/transport/resource_envelope.dart';

class ResourceDocument implements Document {
  final ResourceEnvelope resourceEnvelope;
  final List<ResourceEnvelope> included;
  final Link self;

  ResourceDocument(this.resourceEnvelope, {List<ResourceEnvelope> included, this.self})
      : included = List.unmodifiable(included ?? []);

  toJson() {
    final json = <String, Object>{'data': resourceEnvelope};

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
        return ResourceDocument(ResourceEnvelope.fromJson(data));
      }
      if (data == null) {
        return ResourceDocument(null);
      }
    }
    throw 'Can not parse ResourceDocument from $json';
  }
}
