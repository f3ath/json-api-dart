import 'package:json_api/src/document/relationship.dart';

class Resource {
  Resource(this.type,
      {Map<String, Object> meta = const {},
      Map<String, Object> attributes = const {},
      Map<String, Relationship> relationships = const {}})
      : meta = Map.unmodifiable(meta ?? {}),
        relationships = Map.unmodifiable(relationships ?? {}),
        attributes = Map.unmodifiable(attributes ?? {});

  final String type;
  final Map<String, Object> meta;
  final Map<String, Object> attributes;
  final Map<String, Relationship> relationships;

  Map<String, Object> toJson() => {
        'type': type,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
