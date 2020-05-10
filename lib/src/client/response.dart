import 'dart:collection';
import 'dart:convert';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart' as d;
import 'package:json_api/http.dart';
import 'package:json_api/src/client/status_code.dart';
import 'package:json_api/src/maybe.dart';

/// A JSON:API response
class Response<D extends d.PrimaryData> {
  Response(this.http, this._decoder);

  final d.PrimaryDataDecoder<D> _decoder;

  /// The HTTP response.
  final HttpResponse http;

  /// Returns the Document parsed from the response body.
  /// Throws a [StateError] if the HTTP response contains empty body.
  /// Throws a [DocumentException] if the received document structure is invalid.
  /// Throws a [FormatException] if the received JSON is invalid.
  d.Document<D> decodeDocument() {
    if (http.body.isEmpty) throw StateError('The HTTP response has empty body');
    return d.Document.fromJson(jsonDecode(http.body), _decoder);
  }

  /// Returns the async Document parsed from the response body.
  /// Throws a [StateError] if the HTTP response contains empty body.
  /// Throws a [DocumentException] if the received document structure is invalid.
  /// Throws a [FormatException] if the received JSON is invalid.
  d.Document<d.ResourceData> decodeAsyncDocument() {
    if (http.body.isEmpty) throw StateError('The HTTP response has empty body');
    return d.Document.fromJson(jsonDecode(http.body), d.ResourceData.fromJson);
  }

  /// Was the query successful?
  ///
  /// For pending (202 Accepted) requests both [isSuccessful] and [isFailed]
  /// are always false.
  bool get isSuccessful => StatusCode(http.statusCode).isSuccessful;

  /// This property is an equivalent of `202 Accepted` HTTP status.
  /// It indicates that the query is accepted but not finished yet (e.g. queued).
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  bool get isAsync => StatusCode(http.statusCode).isPending;

  /// Any non 2** status code is considered a failed operation.
  /// For failed requests, [document] is expected to contain [ErrorDocument]
  bool get isFailed => StatusCode(http.statusCode).isFailed;
}

class FetchCollectionResponse with IterableMixin<Resource> {
  FetchCollectionResponse(this.http,
      {ResourceCollection resources,
      ResourceCollection included,
      Map<String, Link> links = const {}})
      : resources = resources ?? ResourceCollection(const []),
        links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  static FetchCollectionResponse fromHttp(HttpResponse http) {
    final json = jsonDecode(http.body);
    if (json is Map) {
      final resources = json['data'];
      if (resources is List) {
        final included = json['included'];
        final links = json['links'];
        return FetchCollectionResponse(http,
            resources: ResourceCollection(resources.map(Resource.fromJson)),
            included: ResourceCollection(
                included is List ? included.map(Resource.fromJson) : const []),
            links: links is Map ? Link.mapFromJson(links) : const {});
      }
    }
    throw ArgumentError('Can not parse Resource collection');
  }

  final HttpResponse http;
  final ResourceCollection resources;
  final ResourceCollection included;
  final Map<String, Link> links;

  @override
  Iterator<Resource> get iterator => resources.iterator;
}

class FetchPrimaryResourceResponse {
  FetchPrimaryResourceResponse(this.http, this.resource,
      {ResourceCollection included, Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  static FetchPrimaryResourceResponse fromHttp(HttpResponse http) {
    final json = jsonDecode(http.body);
    if (json is Map) {
      final included = json['included'];
      final links = json['links'];
      return FetchPrimaryResourceResponse(http, Resource.fromJson(json['data']),
          included: ResourceCollection(
              included is List ? included.map(Resource.fromJson) : const []),
          links: links is Map ? Link.mapFromJson(links) : const {});
    }
    throw ArgumentError('Can not parse Resource response');
  }

  final HttpResponse http;
  final Resource resource;
  final ResourceCollection included;
  final Map<String, Link> links;
}

class FetchRelationshipResponse {
  FetchRelationshipResponse(this.http, this.relationship);

  static FetchRelationshipResponse fromHttp(HttpResponse http) {
    final json = jsonDecode(http.body);
    if (json is Map) {
      return FetchRelationshipResponse(
        http,
        Relationship.fromJson(json),
      );
    }
    throw ArgumentError('Can not parse Relationship response');
  }

  final HttpResponse http;
  final Relationship relationship;

  Map<String, Link> get links => relationship.links;
}

class FetchRelatedResourceResponse {
  FetchRelatedResourceResponse(this.http, Resource resource,
      {ResourceCollection included, Map<String, Link> links = const {}})
      : _resource = Just(resource),
        links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  FetchRelatedResourceResponse.empty(this.http,
      {ResourceCollection included, Map<String, Link> links = const {}})
      : _resource = Nothing<Resource>(),
        links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  static FetchRelatedResourceResponse fromHttp(HttpResponse http) {
    final json = jsonDecode(http.body);
    if (json is Map) {
      final included = ResourceCollection(Maybe(json['included'])
          .map((t) => t is List ? t : throw ArgumentError('List expected'))
          .map((t) => t.map(Resource.fromJson))
          .or(const []));
      final links = Maybe(json['links'])
          .map((_) => _ is Map ? _ : throw ArgumentError('Map expected'))
          .map(Link.mapFromJson)
          .or(const {});
      return Maybe(json['data'])
          .map(Resource.fromJson)
          .map((resource) => FetchRelatedResourceResponse(http, resource,
              included: included, links: links))
          .orGet(() => FetchRelatedResourceResponse.empty(http,
              included: included, links: links));
    }
    throw ArgumentError('Can not parse Resource response');
  }

  final HttpResponse http;
  final Maybe<Resource> _resource;

  Resource resource({Resource Function() orElse}) => _resource.orGet(() =>
      Maybe(orElse).orThrow(() => StateError('Related resource is empty'))());
  final ResourceCollection included;
  final Map<String, Link> links;
}

class RequestFailure {
  RequestFailure(this.http, {Iterable<ErrorObject> errors = const []})
      : errors = List.unmodifiable(errors ?? const []);
  final List<ErrorObject> errors;

  static RequestFailure decode(HttpResponse http) => Maybe(http.body)
      .filter((_) => _.isNotEmpty)
      .map(jsonDecode)
      .map((_) => _ is Map ? _ : throw ArgumentError('Map expected'))
      .map((_) => _['errors'])
      .map((_) => _ is List ? _ : throw ArgumentError('List expected'))
      .map((_) => _.map(ErrorObject.fromJson))
      .map((_) => RequestFailure(http, errors: _))
      .orGet(() => RequestFailure(http));

  final HttpResponse http;
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
          source: Maybe(json['source'])
              .map(ErrorSource.fromJson)
              .orGet(() => ErrorSource()),
          meta: json['meta'],
          links: Maybe(json['links']).map(Link.mapFromJson).orGet(() => {}));
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

class ResourceCollection with IterableMixin<Resource> {
  ResourceCollection(Iterable<Resource> resources)
      : _map = Map.fromEntries(resources.map((_) => MapEntry(_.key, _)));

  final Map<String, Resource> _map;

  @override
  Iterator<Resource> get iterator => _map.values.iterator;
}

class Resource with Identity {
  Resource(this.type, this.id,
      {Map<String, Link> links,
      Map<String, Object> meta,
      Map<String, Object> attributes,
      Map<String, Relationship> relationships})
      : links = Map.unmodifiable(links ?? {}),
        meta = Map.unmodifiable(meta ?? {}),
        relationships = Map.unmodifiable(relationships ?? {}),
        attributes = Map.unmodifiable(attributes ?? {});

  static Resource fromJson(Object json) {
    if (json is Map) {
      final relationships = json['relationships'];
      final attributes = json['attributes'];
      final type = json['type'];
      if ((relationships == null || relationships is Map) &&
          (attributes == null || attributes is Map) &&
          type is String &&
          type.isNotEmpty) {
        return Resource(json['type'], json['id'],
            attributes: attributes,
            relationships: Maybe(relationships)
                .map((_) => _ is Map ? _ : throw ArgumentError('Map expected'))
                .map((t) => t.map((key, value) =>
                    MapEntry(key.toString(), Relationship.fromJson(value))))
                .orGet(() => {}),
            links: Link.mapFromJson(json['links'] ?? {}),
            meta: json['meta']);
      }
      throw ArgumentError('Invalid JSON:API resource object');
    }
    throw ArgumentError('A JSON:API resource must be a JSON object');
  }

  @override
  final String type;
  @override
  final String id;
  final Map<String, Link> links;
  final Map<String, Object> meta;
  final Map<String, Object> attributes;
  final Map<String, Relationship> relationships;

  Many many(String key, {Many Function() orElse}) => Maybe(relationships[key])
      .filter((_) => _ is Many)
      .orGet(() => Maybe(orElse).orThrow(() => StateError('No element'))());

  One one(String key, {One Function() orElse}) => Maybe(relationships[key])
      .filter((_) => _ is One)
      .orGet(() => Maybe(orElse).orThrow(() => StateError('No element'))());
}

class Relationship with IterableMixin<Identifier> {
  Relationship({Map<String, Link> links, Map<String, Object> meta})
      : links = Map.unmodifiable(links ?? {}),
        meta = Map.unmodifiable(meta ?? {});

  /// Reconstructs a JSON:API Document or the `relationship` member of a Resource object.
  static Relationship fromJson(Object json) {
    if (json is Map) {
      final links = Maybe(json['links']).map(Link.mapFromJson).or(const {});
      final meta = json['meta'];
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
      return Relationship(links: links, meta: meta);
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
  Iterator<Identifier> get iterator => const [].iterator;
}

class One extends Relationship {
  One(Identifier identifier,
      {Map<String, Link> links, Map<String, Object> meta})
      : _id = Just(identifier),
        super(links: links, meta: meta);

  One.empty({Map<String, Link> links, Map<String, Object> meta})
      : _id = Nothing<Identifier>(),
        super(links: links, meta: meta);

  final Maybe<Identifier> _id;

  @override
  final isSingular = true;

  @override
  Map<String, Object> toJson() => {...super.toJson(), 'data': _id.or(null)};

  Identifier identifier({Identifier Function() ifEmpty}) => _id.orGet(
      () => Maybe(ifEmpty).orThrow(() => StateError('Empty relationship'))());

  @override
  Iterator<Identifier> get iterator =>
      _id.map((_) => [_]).or(const []).iterator;
}

class Many extends Relationship {
  Many(Iterable<Identifier> identifiers,
      {Map<String, Link> links, Map<String, Object> meta})
      : super(links: links, meta: meta) {
    identifiers.forEach((_) => _map[_.key] = _);
  }

  final _map = <String, Identifier>{};

  @override
  final isPlural = true;

  @override
  Map<String, Object> toJson() => {...super.toJson(), 'data': _map.values};

  @override
  Iterator<Identifier> get iterator => _map.values.iterator;
}

class Identifier with Identity {
  Identifier(this.type, this.id, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {});

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
}

mixin Identity {
  String get type;

  String get id;

  String get key => '$type:$id';
}
