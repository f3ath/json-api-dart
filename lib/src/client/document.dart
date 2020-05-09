import 'dart:collection';
class ContentType {
  static const jsonApi = 'application/vnd.api+json';
}

abstract class RequestDocument {
  Api get api;

  Map<String, Object> get meta;

  Map<String, Object> toJson();
}

class ResourceDocument implements RequestDocument {
  ResourceDocument(
    this.resource, {
    Api api,
    Map<String, Object> meta,
  })  : meta = Map.unmodifiable(meta ?? {}),
        api = api ?? Api();

  final GenericResource resource;
  @override
  final Api api;
  @override
  final Map<String, Object> meta;

  @override
  Map<String, Object> toJson() => {
        'data': resource.toJson(),
        if (meta.isNotEmpty) 'meta': meta,
        if (api.isNotEmpty) 'jsonapi': api.toJson()
      };
}

class RelationshipDocument implements RequestDocument {
  RelationshipDocument(this.relationship, {Api api}) : api = api ?? Api();

  final Relationship relationship;

  @override
  final Api api;

  @override
  Map<String, Object> get meta => relationship.meta;

  @override
  Map<String, Object> toJson() =>
      {...relationship.toJson(), if (api.isNotEmpty) 'jsonapi': api.toJson()};
}

abstract class GenericResource {
  Map<String, Object> toJson();
}

class NewResource implements GenericResource {
  NewResource(
    this.type, {
    Map<String, Object> attributes,
    Map<String, Object> meta,
    Map<String, Relationship> relationships,
  })  : attributes = Map.unmodifiable(attributes ?? {}),
        meta = Map.unmodifiable(meta ?? {}),
        relationships = Map.unmodifiable(relationships ?? {});

  final String type;
  final Map<String, Object> meta;
  final Map<String, Object> attributes;
  final Map<String, Relationship> relationships;

  @override
  Map<String, Object> toJson() => {
        'type': type,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (meta.isNotEmpty) 'meta': meta,
      };
}

class Resource implements GenericResource {
  Resource(
    this.type,
    this.id, {
    Map<String, Object> attributes,
    Map<String, Object> meta,
    Map<String, Relationship> relationships,
  })  : attributes = Map.unmodifiable(attributes ?? {}),
        meta = Map.unmodifiable(meta ?? {}),
        relationships = Map.unmodifiable(relationships ?? {});

  final String type;
  final String id;
  final Map<String, Object> meta;
  final Map<String, Object> attributes;
  final Map<String, Relationship> relationships;

  @override
  Map<String, Object> toJson() => {
        'type': type,
        'id': id,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (meta.isNotEmpty) 'meta': meta,
      };
}

abstract class Relationship implements Iterable<Identifier> {
  Map<String, Object> toJson();

  Map<String, Object> get meta;
}

class One with IterableMixin<Identifier> implements Relationship {
  One(Identifier identifier, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {}),
        _ids = List.unmodifiable([identifier]);

  One.empty({Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {}),
        _ids = const [];

  @override
  final Map<String, Object> meta;
  final List<Identifier> _ids;

  @override
  Iterator<Identifier> get iterator => _ids.iterator;

  @override
  Map<String, Object> toJson() => {
        if (meta.isNotEmpty) 'meta': meta,
        'data': _ids.isEmpty ? null : _ids.first,
      };
}

class Many with IterableMixin<Identifier> implements Relationship {
  Many(Iterable<Identifier> identifiers, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {}),
        _ids = List.unmodifiable(identifiers);

  @override
  final Map<String, Object> meta;
  final List<Identifier> _ids;

  @override
  Iterator<Identifier> get iterator => _ids.iterator;

  @override
  Map<String, Object> toJson() => {
        if (meta.isNotEmpty) 'meta': meta,
        'data': _ids,
      };
}

class Identifier {
  Identifier(this.type, this.id, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {}) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
  }

  final String type;

  final String id;

  final Map<String, Object> meta;

  Map<String, Object> toJson() => {
        'type': type,
        'id': id,
        if (meta.isNotEmpty) 'meta': meta,
      };
}

class Api {
  Api({String version, Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {}),
        version = version ?? '';

  static const v1 = '1.0';

  /// The JSON:API version. May be empty.
  final String version;

  final Map<String, Object> meta;

  bool get isHigherVersion => version.isNotEmpty && version != v1;

  bool get isNotEmpty => version.isNotEmpty && meta.isNotEmpty;

  Map<String, Object> toJson() => {
        if (version.isNotEmpty) 'version': version,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
