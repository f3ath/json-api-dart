import 'dart:collection';

import 'package:json_api/src/nullable.dart';

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

  final MinimalResource resource;
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

abstract class MinimalResource {
  MinimalResource(this.type,
      {Map<String, Object> attributes,
      Map<String, Object> meta,
      Map<String, Relationship> relationships})
      : attributes = Map.unmodifiable(attributes ?? {}),
        meta = Map.unmodifiable(meta ?? {}),
        relationships = Map.unmodifiable(relationships ?? {});

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

class NewResource extends MinimalResource {
  NewResource(String type,
      {Map<String, Object> attributes,
      Map<String, Object> meta,
      Map<String, Relationship> relationships})
      : super(type,
            attributes: attributes, relationships: relationships, meta: meta);
}

class Resource extends MinimalResource with Identity {
  Resource(String type, this.id,
      {Map<String, Object> attributes,
      Map<String, Object> meta,
      Map<String, Relationship> relationships})
      : super(type,
            attributes: attributes, relationships: relationships, meta: meta);

  @override
  final String id;

  @override
  Map<String, Object> toJson() => super.toJson()..['id'] = id;
}

abstract class Relationship implements Iterable<Identifier> {
  Map<String, Object> toJson();

  Map<String, Object> get meta;

//  static Relationship fromJson(Object json) {
//    if (json is Map) {
//      final data = json['data'];
//      if (data is List)
//
//    }
//
//    throw ArgumentError('Can not parse Relationship');
//  }
}

class One with IterableMixin<Identifier> implements Relationship {
  One(Identifier identifier, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {}),
        _ids = List.unmodifiable([identifier]);

  One.empty({Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {}),
        _ids = const [];

  One.fromNullable(Identifier identifier, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {}),
        _ids = identifier == null ? const [] : [identifier];

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

class Identifier with Identity {
  Identifier(this.type, this.id, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {}) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
  }

  static Identifier fromJson(Object json) {
    if (json is Map) {
      return Identifier(json['type'], json['id'], meta: json['meta']);
    }
    throw ArgumentError('A JSON:API identifier must be a JSON object');
  }

  @override
  final String type;

  @override
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

mixin Identity {
  String get type;

  String get id;

  String get key => '$type:$id';
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
    String id,
    String status,
    String code,
    String title,
    String detail,
    Map<String, Object> meta,
    ErrorSource source,
    Map<String, Link> links,
  })  : id = id ?? '',
        status = status ?? '',
        code = code ?? '',
        title = title ?? '',
        detail = detail ?? '',
        source = source ?? ErrorSource(),
        meta = Map.unmodifiable(meta ?? {}),
        links = Map.unmodifiable(links ?? {});

  static ErrorObject fromJson(Object json) {
    if (json is Map) {
      return ErrorObject(
              id: json['id'],
              status: json['status'],
              code: json['code'],
              title: json['title'],
              detail: json['detail'],
              source: nullable(ErrorSource.fromJson)(json['source']) ??
                  ErrorSource(),
              meta: json['meta'],
              links: nullable(Link.mapFromJson)(json['links'])) ??
          {};
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

  /// The `source` object.
  final ErrorSource source;

  final Map<String, Object> meta;
  final Map<String, Link> links;

  Map<String, Object> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (status.isNotEmpty) 'status': status,
      if (code.isNotEmpty) 'code': code,
      if (title.isNotEmpty) 'title': title,
      if (detail.isNotEmpty) 'detail': detail,
      if (meta.isNotEmpty) 'meta': meta,
      if (links.isNotEmpty) 'links': links,
      if (source.isNotEmpty) 'source': source,
    };
  }
}

/// An object containing references to the source of the error, optionally including any of the following members:
/// - pointer: a JSON Pointer (RFC6901) to the associated entity in the request document,
///   e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute.
/// - parameter: a string indicating which URI query parameter caused the error.
class ErrorSource {
  ErrorSource({String pointer, String parameter})
      : pointer = pointer ?? '',
        parameter = parameter ?? '';

  static ErrorSource fromJson(Object json) {
    if (json is Map) {
      return ErrorSource(
          pointer: json['pointer'], parameter: json['parameter']);
    }
    throw ArgumentError('Can not parse ErrorSource');
  }

  final String pointer;

  final String parameter;

  bool get isNotEmpty => pointer.isNotEmpty || parameter.isNotEmpty;

  Map<String, Object> toJson() => {
        if (pointer.isNotEmpty) 'pointer': pointer,
        if (parameter.isNotEmpty) 'parameter': parameter
      };
}

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link {
  Link(this.uri, {Map<String, Object> meta = const {}}) : meta = meta ?? {} {
    ArgumentError.checkNotNull(uri, 'uri');
  }

  final Uri uri;
  final Map<String, Object> meta;

  /// Reconstructs the link from the [json] object
  static Link fromJson(Object json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      return Link(Uri.parse(json['href']), meta: json['meta']);
    }
    throw ArgumentError(
        'A JSON:API link must be a JSON string or a JSON object');
  }

  /// Reconstructs the document's `links` member into a map.
  /// Details on the `links` member: https://jsonapi.org/format/#document-links
  static Map<String, Link> mapFromJson(Object json) {
    if (json is Map) {
      return json.map((k, v) => MapEntry(k.toString(), Link.fromJson(v)));
    }
    throw ArgumentError('A JSON:API links object must be a JSON object');
  }

  Object toJson() =>
      meta.isEmpty ? uri.toString() : {'href': uri.toString(), 'meta': meta};

  @override
  String toString() => uri.toString();
}
