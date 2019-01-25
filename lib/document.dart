class ParseError implements Exception {
  final Type type;
  final Object json;

  ParseError(this.type, this.json);

  @override
  String toString() => 'Can not parse $type from $json';
}

/// A violation of JSON:API naming
/// https://jsonapi.org/format/#document-member-names
class NamingViolation {
  final String path;
  final String value;

  NamingViolation(this.path, this.value);
}

/// JSON:API naming rules
/// https://jsonapi.org/format/#document-member-names
abstract class Naming {
  const Naming();

  Iterable<NamingViolation> violations(String path, Iterable<String> values);
}

class Prefixed implements Naming {
  final Naming inner;
  final String prefix;

  Prefixed(this.inner, this.prefix);

  @override
  Iterable<NamingViolation> violations(String path, Iterable<String> values) =>
      inner.violations(prefix + path, values);
}

/// JSON:API standard naming rules
/// https://jsonapi.org/format/#document-member-names
class StandardNaming extends Naming {
  static final _disallowFirst = new RegExp(r'^[^_ -]');
  static final _disallowLast = new RegExp(r'[^_ -]$');
  static final _allowGlobally = new RegExp(r'^[a-zA-Z0-9_ \u0080-\uffff-]+$');

  const StandardNaming();

  /// Is [name] allowed by the rules
  bool allows(String name) =>
      _disallowFirst.hasMatch(name) &&
      _disallowLast.hasMatch(name) &&
      _allowGlobally.hasMatch(name);

  bool disallows(String name) => !allows(name);

  Iterable<NamingViolation> violations(String path, Iterable<String> values) =>
      values.where(disallows).map((_) => NamingViolation(path, _));
}

abstract class DocumentMember {
  Iterable<NamingViolation> namingViolations(
      [Naming naming = const StandardNaming()]);

  Object toJson();
}

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link implements DocumentMember {
  final String href;

  Link(String this.href) {
    if (href == null) throw ArgumentError.notNull('href');
  }

  toJson() => href;

  factory Link.fromJson(Object json) {
    if (json is String) return Link(json);
    if (json is Map) return LinkObject.fromJson(json);
    throw ParseError(Link, json);
  }

  namingViolations([Naming naming = const StandardNaming()]) => [];
}

/// A JSON:API link object
/// https://jsonapi.org/format/#document-links
class LinkObject extends Link {
  final meta = <String, Object>{};

  LinkObject(String href, {Map<String, Object> meta}) : super(href) {
    this.meta.addAll(meta ?? {});
  }

  toJson() {
    final json = <String, Object>{'href': href};
    if (meta != null && meta.isNotEmpty) json['meta'] = meta;
    return json;
  }

  factory LinkObject.fromJson(Map json) =>
      LinkObject(json['href'], meta: json['meta']);

  namingViolations([Naming naming = const StandardNaming()]) =>
      naming.violations('/meta', (meta).keys);
}

/// JSON:API identifier object
/// https://jsonapi.org/format/#document-resource-identifier-objects
class Identifier implements DocumentMember {
  final String type;
  final String id;
  final meta = <String, Object>{};

  Identifier(this.type, this.id, {Map<String, Object> meta}) {
    this.meta.addAll(meta ?? {});
    if (id == null) throw ArgumentError.notNull('id');
    if (type == null) throw ArgumentError.notNull('type');
  }

  namingViolations([Naming naming = const StandardNaming()]) =>
      naming.violations(
          '/type', [type]).followedBy(naming.violations('/meta', (meta).keys));

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (meta.isNotEmpty) json['meta'] = meta;
    return json;
  }

  factory Identifier.fromJson(Map json) =>
      Identifier(json['type'], json['id'], meta: json['meta']);
}

abstract class Relationship implements DocumentMember {
  Link self;
  Link related;

  Object get data;

  Object toJson() {
    final json = {'data': data};
    final links = {'self': self?.toJson(), 'related': related?.toJson()}
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
    if (identifier == null) throw ArgumentError.notNull('identifier');
  }

  Object get data => identifier.toJson();

  Iterable<NamingViolation> namingViolations(
          [Naming naming = const StandardNaming()]) =>
      identifier.namingViolations(naming);
}

class ToMany extends Relationship {
  final Iterable<Identifier> identifiers;

  ToMany(this.identifiers) {}

  Object get data => identifiers.map((_) => toJson());

  Iterable<NamingViolation> namingViolations(
          [Naming naming = const StandardNaming()]) =>
      identifiers.toList().asMap().entries.expand(
          (_) => _.value.namingViolations(Prefixed(naming, '/${_.key}')));
}

class Resource implements DocumentMember {
  final String type;
  final String id;
  final attributes = <String, Object>{};
  final toOne = <String, Identifier>{};
  final toMany = <String, Iterable<Identifier>>{};
  final meta = <String, Object>{};
  Link self;

  Resource(this.type, this.id,
      {this.self,
      Map<String, Object> meta,
      Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, Iterable<Identifier>> toMany}) {
    this.attributes.addAll(attributes ?? {});
    this.toOne.addAll(toOne ?? {});
    this.toMany.addAll(toMany ?? {});
    this.meta.addAll(meta ?? {});
    if (type == null) throw ArgumentError.notNull('type');
  }

  Map<String, Relationship> get relationships => Map.fromIterables(
      toOne.keys, toOne.values.map((_) => ToOne(_)))
    ..addAll(
        Map.fromIterables(toMany.keys, toMany.values.map((_) => ToMany(_))));

  namingViolations([Naming naming = const StandardNaming()]) => naming
      .violations('/type', [type])
      .followedBy(naming.violations('/meta', meta.keys))
      .followedBy(naming.violations('/attributes', attributes.keys))
      .followedBy(naming.violations('/relationships', relationships.keys))
      .followedBy(relationships.entries.expand((rel) => rel.value
          .namingViolations(Prefixed(naming, '/relationships/${rel.key}'))));

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (attributes.isNotEmpty) json['attributes'] = attributes;
    if (meta.isNotEmpty) json['meta'] = meta;
    if (self is Link) json['links'] = {'self': self.toJson()};
    return json;
  }

  factory Resource.fromJson(Map json) =>
      Resource(json['type'], json['id'], meta: json['meta']);
}
