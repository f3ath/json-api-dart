import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/validation.dart';

/// Resource object
class Resource implements Validatable {
  final String type;
  final String id;
  final Link self;
  final attributes = <String, Object>{};
  final meta = <String, Object>{};
  final relationships = <String, Relationship>{};

  Resource(this.type, this.id,
      {Map<String, Object> meta,
      Map<String, Object> attributes,
      Map<String, Relationship> relationships,
      this.self}) {
    ArgumentError.checkNotNull(type, 'type');
    this.attributes.addAll(attributes ?? {});
    this.relationships.addAll(relationships ?? {});
    this.meta.addAll(meta ?? {});
  }

  /// Violations of the JSON:API standard
  validate(Naming naming) {
    final fields = Set.of(['type', 'id']);
    final rel = Set.of(relationships.keys);
    final attr = Set.of(attributes.keys);
    final namespaceViolations = fields
        .intersection(rel)
        .map((_) => NamespaceViolation('/relationships', _))
        .followedBy(fields
            .intersection(attr)
            .map((_) => NamespaceViolation('/attributes', _)))
        .followedBy(
            attr.intersection(rel).map((_) => NamespaceViolation('/fields', _)))
        .toList();

    return (<Violation>[] +
            namespaceViolations +
            naming.violations('/type', [type]) +
            naming.violations('/meta', meta.keys) +
            naming.violations('/attributes', attributes.keys) +
            naming.violations('/relationships', relationships.keys) +
            relationships.entries
                .expand((rel) => rel.value
                    .validate(Prefixed(naming, '/relationships/${rel.key}')))
                .toList())
        .toList();
  }

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (attributes.isNotEmpty) json['attributes'] = attributes;
    if (relationships.isNotEmpty) json['relationships'] = relationships;
    if (meta.isNotEmpty) json['meta'] = meta;
    if (self != null) json['links'] = {'self': self};
    return json;
  }

  Resource.fromJson(Map json)
      : this(json['type'], json['id'], meta: json['meta']);
}
