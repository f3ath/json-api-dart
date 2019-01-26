import 'package:json_api/src/link.dart';
import 'package:json_api/src/validation.dart';

abstract class Relationship implements Validatable {
  Link self;
  Link related;

  Object get data;

  Object toJson() {
    final json = {'data': data};
    final links = {'self': self, 'related': related}
      ..removeWhere((k, v) => v == null);
    if (links.isNotEmpty) {
      json['links'] = links;
    }
    return json;
  }
}

class ToOne extends Relationship {
  final Identifier identifier;

  ToOne(this.identifier) {
    ArgumentError.checkNotNull(identifier, 'identifier');
  }

  Object get data => identifier;

  validate([Naming naming = const StandardNaming()]) =>
      identifier.validate(naming);
}

class ToMany extends Relationship {
  final List<Identifier> identifiers;

  ToMany(this.identifiers) {}

  Object get data => identifiers.toList();

  validate([Naming naming = const StandardNaming()]) => identifiers
      .toList()
      .asMap()
      .entries
      .expand((_) => _.value.validate(Prefixed(naming, '/${_.key}')))
      .toList();
}

class Resource implements Validatable {
  final String type;
  final String id;
  final attributes = <String, Object>{};
  final toOne = <String, Identifier>{};
  final toMany = <String, List<Identifier>>{};
  final meta = <String, Object>{};
  final relationships = <String, Relationship>{};

  Link self;

  Resource(this.type, this.id,
      {this.self,
      Map<String, Object> meta,
      Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, List<Identifier>> toMany}) {
    ArgumentError.checkNotNull(type, 'type');
    this.attributes.addAll(attributes ?? {});
    this.meta.addAll(meta ?? {});

    toOne ??= {};
    toMany ??= {};
    relationships.addAll(
        Map.fromIterables(toOne.keys, toOne.values.map((_) => ToOne(_))));
    relationships.addAll(
        Map.fromIterables(toMany.keys, toMany.values.map((_) => ToMany(_))));
  }

  /// Violations of the JSON:API standard
  validate([Naming naming = const StandardNaming()]) => (<Violation>[] +
          _namespaceViolations() +
          naming.violations('/type', [type]) +
          naming.violations('/meta', meta.keys) +
          naming.violations('/attributes', attributes.keys) +
          naming.violations('/relationships', relationships.keys) +
          relationships.entries
              .expand((rel) => rel.value
                  .validate(Prefixed(naming, '/relationships/${rel.key}')))
              .toList())
      .toList();

  List<Violation> _namespaceViolations() {
    final fields = Set.of(['type', 'id']);
    final rel = Set.of(relationships.keys);
    final attr = Set.of(attributes.keys);
    return fields
        .intersection(rel)
        .map((_) => NamespaceViolation('/relationships', _))
        .followedBy(fields
            .intersection(attr)
            .map((_) => NamespaceViolation('/attributes', _)))
        .followedBy(
            attr.intersection(rel).map((_) => NamespaceViolation('/fields', _)))
        .toList();
  }

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (attributes.isNotEmpty) json['attributes'] = attributes;
    if (relationships.isNotEmpty) json['relationships'] = relationships;
    if (meta.isNotEmpty) json['meta'] = meta;
    if (self is Link) json['links'] = {'self': self};
    return json;
  }

  Resource.fromJson(Map json)
      : this(json['type'], json['id'], meta: json['meta']);

  void setLinks(LinkFactory link) {
    self = link.resource(type, id);
    relationships.forEach((name, rel) {
      rel.self = link.relationship(type, id, name);
      rel.related = link.related(type, id, name);
    });
  }
}

/// JSON:API identifier object
/// https://jsonapi.org/format/#document-resource-identifier-objects
class Identifier implements Validatable {
  final String type;
  final String id;
  final meta = <String, Object>{};

  Identifier(this.type, this.id, {Map<String, Object> meta}) {
    this.meta.addAll(meta ?? {});
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(type, 'type');
  }

  validate([Naming naming = const StandardNaming()]) =>
      (naming.violations('/type', [type]) +
              naming.violations('/meta', meta.keys))
          .toList();

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (meta.isNotEmpty) json['meta'] = meta;
    return json;
  }

  factory Identifier.fromJson(Map json) =>
      Identifier(json['type'], json['id'], meta: json['meta']);

  factory Identifier.of(Resource r) => Identifier(r.type, r.id);
}
