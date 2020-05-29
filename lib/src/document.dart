import 'dart:collection';

import 'package:maybe_just_nothing/maybe_just_nothing.dart';

/// A generic response document
class Document {
  Document(dynamic json)
      : json = json is Map<String, Object>
            ? json
            : throw ArgumentError('Invalid JSON');

  final Map json;

  bool get hasData => json.containsKey('data');

  Maybe<Object> get data => Maybe(json['data']);

  Maybe<Map<String, Object>> get meta =>
      Maybe(json['meta']).cast<Map<String, Object>>();

  Maybe<Map<String, Link>> get links => path<Map>(['links']).map((_) =>
      _.map((key, value) => MapEntry(key.toString(), Link.fromJson(value))));

  Maybe<List<ResourceWithIdentity>> get included => path<List>(['included'])
      .map((_) => _.map(ResourceWithIdentity.fromJson).toList());

  /// Returns the value at the [path] if both are true:
  /// - the path exists
  /// - the value is of type T
  Maybe<T> path<T>(List<String> path) => _path(path, Maybe(json));

  Maybe<T> _path<T>(List<String> path, Maybe<Map> json) {
    if (path.isEmpty) throw ArgumentError('Empty path');
    final value = json.flatMap((_) => Maybe(_[path.first]));
    if (path.length == 1) return value.cast<T>();
    return _path<T>(path.sublist(1), value.cast<Map>());
  }
}

/// [ErrorObject] represents an error occurred on the server.
///
/// More on this: https://jsonapi.org/format/#errors
class ErrorObject {
  /// Creates an instance of a JSON:API Error.
  /// The [links] map may contain custom links. The about link
  /// passed through the [links['about']] argument takes precedence and will overwrite
  /// the `about` key in [links].
  ErrorObject({
    String id = '',
    String status = '',
    String code = '',
    String title = '',
    String detail = '',
    Map<String, Object> meta = const {},
    String sourceParameter = '',
    String sourcePointer = '',
    Map<String, Link> links = const {},
  })  : id = id ?? '',
        status = status ?? '',
        code = code ?? '',
        title = title ?? '',
        detail = detail ?? '',
        sourcePointer = sourcePointer ?? '',
        sourceParameter = sourceParameter ?? '',
        meta = Map.unmodifiable(meta ?? {}),
        links = Map.unmodifiable(links ?? {});

  static ErrorObject fromJson(dynamic json) {
    if (json is Map) {
      final document = Document(json);
      return ErrorObject(
          id: Maybe(json['id']).cast<String>().or(''),
          status: Maybe(json['status']).cast<String>().or(''),
          code: Maybe(json['code']).cast<String>().or(''),
          title: Maybe(json['title']).cast<String>().or(''),
          detail: Maybe(json['detail']).cast<String>().or(''),
          sourceParameter:
              document.path<String>(['source', 'parameter']).or(''),
          sourcePointer: document.path<String>(['source', 'pointer']).or(''),
          meta: document.meta.or(const {}),
          links: document.links.or(const {}));
    }
    throw ArgumentError('A JSON:API error must be a JSON object');
  }

  /// A unique identifier for this particular occurrence of the problem.
  /// May be empty.
  final String id;

  /// The HTTP status code applicable to this problem, expressed as a string value.
  /// May be empty.
  final String status;

  /// An application-specific error code, expressed as a string value.
  /// May be empty.
  final String code;

  /// A short, human-readable summary of the problem that SHOULD NOT change
  /// from occurrence to occurrence of the problem, except for purposes of localization.
  /// May be empty.
  final String title;

  /// A human-readable explanation specific to this occurrence of the problem.
  /// Like title, this field’s value can be localized.
  /// May be empty.
  final String detail;

  /// A JSON Pointer (RFC6901) to the associated entity in the request document,
  ///   e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute.
  final String sourcePointer;

  /// A string indicating which URI query parameter caused the error.
  final String sourceParameter;

  /// Meta data.
  final Map<String, Object> meta;

  /// Error links. May be empty.
  final Map<String, Link> links;
}

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link {
  Link(this.uri, {Map<String, Object> meta = const {}})
      : meta = Map.unmodifiable(meta ?? const {}) {
    ArgumentError.checkNotNull(uri, 'uri');
  }

  final Uri uri;
  final Map<String, Object> meta;

  /// Reconstructs the link from the [json] object
  static Link fromJson(dynamic json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      final document = Document(json);
      return Link(
          Maybe(json['href']).cast<String>().map(Uri.parse).orGet(() => Uri()),
          meta: document.meta.or(const {}));
    }
    throw ArgumentError(
        'A JSON:API link must be a JSON string or a JSON object');
  }

  /// Reconstructs the document's `links` member into a map.
  /// Details on the `links` member: https://jsonapi.org/format/#document-links
  static Maybe<Map<String, Link>> mapFromJson(dynamic json) => Maybe(json)
      .cast<Map>()
      .map((_) => _.map((k, v) => MapEntry(k.toString(), Link.fromJson(v))));

  @override
  String toString() => uri.toString();
}

class IdentityCollection<T extends Identity> with IterableMixin<T> {
  IdentityCollection(Iterable<T> resources)
      : _map = Map<String, T>.fromIterable(resources, key: (_) => _.key);

  final Map<String, T> _map;

  Maybe<T> get(String key) => Maybe(_map[key]);

  @override
  Iterator<T> get iterator => _map.values.iterator;
}

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

class ResourceWithIdentity extends Resource with Identity {
  ResourceWithIdentity(this.type, this.id,
      {Map<String, Link> links = const {},
      Map<String, Object> meta = const {},
      Map<String, Object> attributes = const {},
      Map<String, Relationship> relationships = const {}})
      : links = Map.unmodifiable(links ?? {}),
        super(type,
            attributes: attributes, relationships: relationships, meta: meta);

  static ResourceWithIdentity fromJson(dynamic json) {
    if (json is Map) {
      return ResourceWithIdentity(
          Maybe(json['type'])
              .cast<String>()
              .orThrow(() => ArgumentError('Invalid type')),
          Maybe(json['id'])
              .cast<String>()
              .orThrow(() => ArgumentError('Invalid id')),
          attributes: Maybe(json['attributes']).cast<Map>().or(const {}),
          relationships: Maybe(json['relationships'])
              .cast<Map>()
              .map((t) => t.map((key, value) =>
                  MapEntry(key.toString(), Relationship.fromJson(value))))
              .orGet(() => {}),
          links: Link.mapFromJson(json['links']).or(const {}),
          meta: json['meta']);
    }
    throw ArgumentError('A JSON:API resource must be a JSON object');
  }

  @override
  final String type;
  @override
  final String id;
  final Map<String, Link> links;

  Maybe<Many> many(String key) => Maybe(relationships[key]).cast<Many>();

  Maybe<One> one(String key) => Maybe(relationships[key]).cast<One>();

  @override
  Map<String, Object> toJson() => {
        'id': id,
        ...super.toJson(),
        if (links.isNotEmpty) 'links': links,
      };
}

abstract class Relationship with IterableMixin<Identifier> {
  Relationship(
      {Map<String, Link> links = const {}, Map<String, Object> meta = const {}})
      : links = Map.unmodifiable(links ?? {}),
        meta = Map.unmodifiable(meta ?? {});

  /// Reconstructs a JSON:API Document or the `relationship` member of a Resource object.
  static Relationship fromJson(dynamic json) {
    if (json is Map) {
      final document = Document(json);
      final links = document.links.or(const {});
      final meta = document.meta.or(const {});
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data == null) {
          return One.empty(links: links, meta: meta);
        }
        if (data is Map) {
          return One(Identifier.fromJson(data), links: links, meta: meta);
        }
        if (data is List) {
          return Many(data.map(Identifier.fromJson), links: links, meta: meta);
        }
      }
      return IncompleteRelationship(links: links, meta: meta);
    }
    throw ArgumentError('A JSON:API relationship object must be a JSON object');
  }

  final Map<String, Link> links;
  final Map<String, Object> meta;
  final isSingular = false;
  final isPlural = false;
  final hasData = false;

  Map<String, Object> toJson() => {
        if (links.isNotEmpty) 'links': links,
        if (meta.isNotEmpty) 'meta': meta,
      };

  @override
  Iterator<Identifier> get iterator => const <Identifier>[].iterator;

  /// Narrows the type down to R if possible. Otherwise throws the [TypeError].
  R as<R extends Relationship>() => this is R ? this as R : throw TypeError();
}

class IncompleteRelationship extends Relationship {
  IncompleteRelationship(
      {Map<String, Link> links = const {}, Map<String, Object> meta = const {}})
      : super(links: links, meta: meta);
}

class One extends Relationship {
  One(Identifier identifier,
      {Map<String, Link> links = const {}, Map<String, Object> meta = const {}})
      : identifier = Just(identifier),
        super(links: links, meta: meta);

  One.empty(
      {Map<String, Link> links = const {}, Map<String, Object> meta = const {}})
      : identifier = Nothing<Identifier>(),
        super(links: links, meta: meta);

  @override
  final isSingular = true;

  @override
  Map<String, Object> toJson() =>
      {...super.toJson(), 'data': identifier.or(null)};

  Maybe<Identifier> identifier;

  @override
  Iterator<Identifier> get iterator =>
      identifier.map((_) => [_]).or(const []).iterator;
}

class Many extends Relationship {
  Many(Iterable<Identifier> identifiers,
      {Map<String, Link> links = const {}, Map<String, Object> meta = const {}})
      : super(links: links, meta: meta) {
    identifiers.forEach((_) => _map[_.key] = _);
  }

  final _map = <String, Identifier>{};

  @override
  final isPlural = true;

  @override
  Map<String, Object> toJson() =>
      {...super.toJson(), 'data': _map.values.toList()};

  @override
  Iterator<Identifier> get iterator => _map.values.iterator;
}

class Identifier with Identity {
  Identifier(this.type, this.id, {Map<String, Object> meta = const {}})
      : meta = Map.unmodifiable(meta ?? {});

  static Identifier fromJson(dynamic json) {
    if (json is Map) {
      return Identifier(json['type'], json['id'], meta: json['meta']);
    }
    throw ArgumentError('A JSON:API identifier must be a JSON object');
  }

  static Identifier fromKey(String key) {
    final parts = key.split(Identity.delimiter);
    if (parts.length != 2) throw ArgumentError('Invalid key');
    return Identifier(parts.first, parts.last);
  }

  @override
  final String type;

  @override
  final String id;

  final Map<String, Object> meta;

  Map<String, Object> toJson() =>
      {'type': type, 'id': id, if (meta.isNotEmpty) 'meta': meta};
}

mixin Identity {
  static final delimiter = ':';

  String get type;

  String get id;

  String get key => '$type$delimiter$id';

  @override
  String toString() => key;
}
