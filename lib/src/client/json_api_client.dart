import 'dart:convert';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart' as d;
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/maybe.dart';

/// The JSON:API client
class JsonApiClient {
  JsonApiClient(this._http, this._uri);

  final HttpHandler _http;
  final UriFactory _uri;

  /// Fetches a primary resource collection by [type].
  Future<Response<d.ResourceCollectionData>> fetchCollection(String type,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(
        Request.fetchCollection(include: include),
        _uri.collection(type),
        headers: headers,
      );

  /// Fetches a related resource collection. Guesses the URI by [type], [id], [relationship].
  Future<Response<d.ResourceCollectionData>> fetchRelatedCollection(
          String type, String id, String relationship,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(Request.fetchCollection(include: include),
          _uri.related(type, id, relationship),
          headers: headers);

  /// Fetches a primary resource by [type] and [id].
  Future<Response<d.ResourceData>> fetchResource(String type, String id,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(Request.fetchResource(include: include), _uri.resource(type, id),
          headers: headers);

  /// Fetches a related resource by [type], [id], [relationship].
  Future<Response<d.ResourceData>> fetchRelatedResource(
          String type, String id, String relationship,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(Request.fetchResource(include: include),
          _uri.related(type, id, relationship),
          headers: headers);

  /// Fetches a to-one relationship by [type], [id], [relationship].
  Future<Response<d.ToOneObject>> fetchToOne(
          String type, String id, String relationship,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(Request.fetchOne(include: include),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Fetches a to-many relationship by [type], [id], [relationship].
  Future<Response<d.ToManyObject>> fetchToMany(
          String type, String id, String relationship,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(
        Request.fetchMany(include: include),
        _uri.relationship(type, id, relationship),
        headers: headers,
      );

  /// Fetches a [relationship] of [type] : [id].
  Future<Response<d.RelationshipObject>> fetchRelationship(
          String type, String id, String relationship,
          {Map<String, String> headers = const {},
          Iterable<String> include = const []}) =>
      send(Request.fetchRelationship(include: include),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Creates a new [resource] on the server.
  /// The server is expected to assign the resource id.
  Future<Response<d.ResourceData>> createNewResource(String type,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {},
          Map<String, String> headers = const {}}) =>
      send(
          Request.createNewResource(type,
              attributes: attributes, one: one, many: many),
          _uri.collection(type),
          headers: headers);

  /// Creates a new [resource] on the server.
  /// The server is expected to accept the provided resource id.
  Future<Response<d.ResourceData>> createResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {},
          Map<String, String> headers = const {}}) =>
      send(
          Request.createResource(type, id,
              attributes: attributes, one: one, many: many),
          _uri.collection(type),
          headers: headers);

  /// Deletes the resource by [type] and [id].
  Future<Response> deleteResource(String type, String id,
          {Map<String, String> headers = const {}}) =>
      send(Request.deleteResource(), _uri.resource(type, id), headers: headers);

  /// Updates the [resource].
  Future<Response<d.ResourceData>> updateResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {},
          Map<String, String> headers = const {}}) =>
      send(
          Request.updateResource(type, id,
              attributes: attributes, one: one, many: many),
          _uri.resource(type, id),
          headers: headers);

  /// Replaces the to-one [relationship] of [type] : [id].
  Future<Response<d.ToOneObject>> replaceOne(
          String type, String id, String relationship, Identifier identifier,
          {Map<String, String> headers = const {}}) =>
      send(Request.replaceOne(identifier),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Deletes the to-one [relationship] of [type] : [id].
  Future<Response<d.ToOneObject>> deleteOne(
          String type, String id, String relationship,
          {Map<String, String> headers = const {}}) =>
      send(Request.deleteOne(), _uri.relationship(type, id, relationship),
          headers: headers);

  /// Deletes the [identifiers] from the to-many [relationship] of [type] : [id].
  Future<Response<d.ToManyObject>> deleteMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers = const {}}) =>
      send(Request.deleteMany(identifiers),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Replaces the to-many [relationship] of [type] : [id] with the [identifiers].
  Future<Response<d.ToManyObject>> replaceMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers = const {}}) =>
      send(Request.replaceMany(identifiers),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Adds the [identifiers] to the to-many [relationship] of [type] : [id].
  Future<Response<d.ToManyObject>> addMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers = const {}}) =>
      send(Request.addMany(identifiers),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Sends the request to the [uri] via [handler] and returns the response.
  /// Extra [headers] may be added to the request.
  Future<Response<D>> send<D extends d.PrimaryData>(Request<D> request, Uri uri,
      {Map<String, String> headers = const {}}) async {
    final response = await _call(request, uri, headers);
    if (StatusCode(response.statusCode).isFailed) {
      throw RequestFailure.decode(response);
    }
    return Response(response, request.decoder);
  }

  Future<HttpResponse> _call(
          Request request, Uri uri, Map<String, String> headers) =>
      _http.call(_toHttp(request, uri, headers));

  HttpRequest _toHttp(Request request, Uri uri, Map<String, String> headers) =>
      HttpRequest(request.method, request.parameters.addToUri(uri),
          body: request.body, headers: {...?headers, ...request.headers});
}

class RequestFailure {
  RequestFailure(this.http, {Iterable<ErrorObject> errors = const []})
      : errors = List.unmodifiable(errors ?? const []);
  final List<ErrorObject> errors;

  static RequestFailure decode(HttpResponse http) => Maybe(http.body)
      .where((_) => _.isNotEmpty)
      .map(jsonDecode)
      .whereType<Map>()
      .map((_) => _['errors'])
      .whereType<List>()
      .map((_) => _.map(ErrorObject.fromJson))
      .map((_) => RequestFailure(http, errors: _))
      .or(() => RequestFailure(http));

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
              .or(() => ErrorSource()),
          meta: json['meta'],
          links: Maybe(json['links']).map(Link.mapFromJson).or(() => {}));
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
