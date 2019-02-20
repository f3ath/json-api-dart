import 'package:json_api/src/transport/link.dart';
import 'package:json_api/src/transport/relationship.dart';

/// Resource object
class ResourceContainer {
  final String type;
  final String id;
  final Link self;
  final Map<String, Object> attributes;
  final Map<String, Object> meta;
  final Map<String, Relationship> relationships;

  ResourceContainer(this.type, this.id,
      {this.self,
      Map<String, Object> meta,
      Map<String, Object> attributes,
      Map<String, Relationship> relationships})
      : meta = Map.unmodifiable(meta ?? {}),
        attributes = Map.unmodifiable(attributes ?? {}),
        relationships = Map.unmodifiable(relationships ?? {});

  static ResourceContainer fromJson(Object json) {
    if (json is Map) {
      final links = Link.parseMap(json['links'] ?? {});

      return ResourceContainer(
        json['type'],
        json['id'],
        attributes: json['attributes'],
        self: links['self'],
        meta: json['meta'],
        relationships: Relationship.parseMap(json['relationships'] ?? {}),
      );
    }
    throw 'Can not parse ResourceContainer from $json';
  }

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (attributes.isNotEmpty) json['attributes'] = attributes;
    if (relationships.isNotEmpty) json['relationships'] = relationships;
    if (meta.isNotEmpty) json['meta'] = meta;
    if (self != null) json['links'] = {'self': self};
    return json;
  }
}
