import 'package:json_api/src/routing.dart';

export 'package:json_api/src/routing.dart';

class ParseError implements Exception {
  final Type type;
  final Object json;

  ParseError(this.type, this.json);

  @override
  String toString() => 'Can not parse $type from $json';
}

/// A violation of the JSON:API standard
abstract class Violation {
  String get pointer;

  String get value;
}

/// A violation of JSON:API naming
/// https://jsonapi.org/format/#document-member-names
class NamingViolation implements Violation {
  final String pointer;
  final String value;

  NamingViolation(this.pointer, this.value);
}

/// A violation of JSON:API fields uniqueness
/// https://jsonapi.org/format/#document-resource-object-fields
class NamespaceViolation implements Violation {
  final String pointer;
  final String value;

  NamespaceViolation(this.pointer, this.value);
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
  Iterable<Violation> validate([Naming naming = const StandardNaming()]);

  Object toJson();
}

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link implements DocumentMember {
  final String href;

  Link(String this.href) {
    ArgumentError.checkNotNull(href, 'href');
  }

  toJson() => href;

  factory Link.fromJson(Object json) {
    if (json is String) return Link(json);
    if (json is Map) return LinkObject.fromJson(json);
    throw ParseError(Link, json);
  }

  validate([Naming naming = const StandardNaming()]) => [];
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

  validate([Naming naming = const StandardNaming()]) =>
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
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(type, 'type');
  }

  validate([Naming naming = const StandardNaming()]) => naming.violations(
      '/type', [type]).followedBy(naming.violations('/meta', (meta).keys));

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (meta.isNotEmpty) json['meta'] = meta;
    return json;
  }

  factory Identifier.fromJson(Map json) =>
      Identifier(json['type'], json['id'], meta: json['meta']);

  factory Identifier.of(Resource r) => Identifier(r.type, r.id);
}

abstract class Relationship implements DocumentMember {
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
  final Iterable<Identifier> identifiers;

  ToMany(this.identifiers) {}

  Object get data => identifiers.toList();

  validate([Naming naming = const StandardNaming()]) => identifiers
      .toList()
      .asMap()
      .entries
      .expand((_) => _.value.validate(Prefixed(naming, '/${_.key}')));
}

class Resource implements DocumentMember {
  final String type;
  final String id;
  final attributes = <String, Object>{};
  final toOne = <String, Identifier>{};
  final toMany = <String, Iterable<Identifier>>{};
  final meta = <String, Object>{};
  final relationships = <String, Relationship>{};

  Link self;

  Resource(this.type, this.id,
      {this.self,
      Map<String, Object> meta,
      Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, Iterable<Identifier>> toMany}) {
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
  validate([Naming naming = const StandardNaming()]) => <Violation>[]
      .followedBy(naming.violations('/type', [type]))
      .followedBy(naming.violations('/meta', meta.keys))
      .followedBy(naming.violations('/attributes', attributes.keys))
      .followedBy(naming.violations('/relationships', relationships.keys))
      .followedBy(relationships.entries.expand((rel) =>
          rel.value.validate(Prefixed(naming, '/relationships/${rel.key}'))))
      .followedBy(_namespaceViolations());

  _namespaceViolations() {
    final fields = Set.of(['type', 'id']);
    final rel = Set.of(relationships.keys);
    final attr = Set.of(attributes.keys);
    return fields
        .intersection(rel)
        .map((_) => NamespaceViolation('/relationships', _))
        .followedBy(fields
            .intersection(attr)
            .map((_) => NamespaceViolation('/attributes', _)))
        .followedBy(attr
            .intersection(rel)
            .map((_) => NamespaceViolation('/fields', _)));
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

abstract class LinkFactory {
  Link collection(String type, {Map<String, String> queryParameters});

  Link resource(String type, String id);

  Link related(String type, String id, String name);

  Link relationship(String type, String id, String name);
}

class StandardLinks implements LinkFactory {
  final Uri base;

  StandardLinks(this.base) {
    ArgumentError.checkNotNull(base, 'base');
  }

  Link collection(String type, {Map<String, String> queryParameters}) =>
      Link(base
          .replace(
              pathSegments: base.pathSegments.followedBy([type]),
              queryParameters: _nullify({}
                ..addAll(base.queryParameters)
                ..addAll(queryParameters ?? {})))
          .toString());

  Link related(String type, String id, String name) => Link(base
      .replace(pathSegments: base.pathSegments.followedBy([type, id, name]))
      .toString());

  Link relationship(String type, String id, String name) => Link(base
      .replace(
          pathSegments:
              base.pathSegments.followedBy([type, id, 'relationships', name]))
      .toString());

  Link resource(String type, String id) => Link(base
      .replace(pathSegments: base.pathSegments.followedBy([type, id]))
      .toString());

  Map<K, V> _nullify<K, V>(Map<K, V> map) =>
      map?.isNotEmpty == true ? map : null;
}

class CollectionDocument implements DocumentMember {
  final Iterable<Resource> collection;
  final CollectionRoute route;
  final List<Resource> included;
  Link self;
  Link prev;
  Link next;
  Link first;
  Link last;

  CollectionDocument(this.collection, {this.included, this.route}) {}

  Object toJson() {
    final json = <String, Object>{'data': collection};
    final links = <String, Link>{
      'self': self,
      'pref': prev,
      'next': next,
      'first': first,
      'last': last,
    }..removeWhere((k, v) => v == null);
    if (links.isNotEmpty) {
      json['links'] = links;
    }
    if (included?.isNotEmpty == true) json['included'] = included.toList();
    return json;
  }

  @override
  Iterable<Violation> validate([Naming naming = const StandardNaming()]) {
    return collection.expand((_) => _.validate(naming));
  }

  void setLinks(LinkFactory link) {
    self = route?.link(link);
    prev = route?.prevPage?.link(link);
    next = route?.nextPage?.link(link);
    first = route?.firstPage?.link(link);
    last = route?.lastPage?.link(link);
    collection.forEach((_) => _.setLinks(link));
    included.forEach((_) => _.setLinks(link));
  }
}
