import 'dart:convert';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart' as d;
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/document.dart';
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
        Request.fetchCollection(parameters: Include(include)),
        _uri.collection(type),
        headers: headers,
      );

  /// Fetches a related resource collection. Guesses the URI by [type], [id], [relationship].
  Future<Response<d.ResourceCollectionData>> fetchRelatedCollection(
          String type, String id, String relationship,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(Request.fetchCollection(parameters: Include(include)),
          _uri.related(type, id, relationship),
          headers: headers);

  /// Fetches a primary resource by [type] and [id].
  Future<Response<d.ResourceData>> fetchResource(String type, String id,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(Request.fetchResource(parameters: Include(include)),
          _uri.resource(type, id),
          headers: headers);

  /// Fetches a related resource by [type], [id], [relationship].
  Future<Response<d.ResourceData>> fetchRelatedResource(
          String type, String id, String relationship,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(Request.fetchResource(parameters: Include(include)),
          _uri.related(type, id, relationship),
          headers: headers);

  /// Fetches a to-one relationship by [type], [id], [relationship].
  Future<Response<d.ToOneObject>> fetchToOne(
          String type, String id, String relationship,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(Request.fetchToOne(parameters: Include(include)),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Fetches a to-many relationship by [type], [id], [relationship].
  Future<Response<d.ToManyObject>> fetchToMany(
          String type, String id, String relationship,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(
        Request.fetchToMany(parameters: Include(include)),
        _uri.relationship(type, id, relationship),
        headers: headers,
      );

  /// Fetches a [relationship] of [type] : [id].
  Future<Response<d.RelationshipObject>> fetchRelationship(
          String type, String id, String relationship,
          {Map<String, String> headers = const {},
          Iterable<String> include = const []}) =>
      send(Request.fetchRelationship(parameters: Include(include)),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Creates a new [resource] on the server.
  /// The server is expected to assign the resource id.
  Future<Response<d.ResourceData>> createNewResource(String type,
          {Map<String, Object> attributes = const {},
          Map<String, Object> meta = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {},
          Map<String, String> headers = const {}}) =>
      send(
          Request.createResource(ResourceDocument(NewResource(type,
              attributes: attributes,
              relationships: _rel(one: one, many: many),
              meta: meta))),
          _uri.collection(type),
          headers: headers);

  /// Creates a new [resource] on the server.
  /// The server is expected to accept the provided resource id.
  Future<Response<d.ResourceData>> createResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Object> meta = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {},
          Map<String, String> headers = const {}}) =>
      send(
          Request.createResource(ResourceDocument(Resource(type, id,
              attributes: attributes,
              relationships: _rel(one: one, many: many),
              meta: meta))),
          _uri.collection(type),
          headers: headers);

  /// Deletes the resource by [type] and [id].
  Future<Response> deleteResource(String type, String id,
          {Map<String, String> headers = const {}}) =>
      send(Request.deleteResource(), _uri.resource(type, id), headers: headers);

  /// Updates the [resource].
  Future<Response<d.ResourceData>> updateResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Object> meta = const {},
          Map<String, Relationship> relationships = const {},
          Map<String, String> headers = const {}}) =>
      send(
          Request.updateResource(ResourceDocument(Resource(type, id,
              attributes: attributes,
              relationships: relationships,
              meta: meta))),
          _uri.resource(type, id),
          headers: headers);

  /// Replaces the to-one [relationship] of [type] : [id].
  Future<Response<d.ToOneObject>> replaceOne(
          String type, String id, String relationship, Identifier identifier,
          {Map<String, String> headers = const {}}) =>
      send(Request.replaceToOne(RelationshipDocument(One(identifier))),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Deletes the to-one [relationship] of [type] : [id].
  Future<Response<d.ToOneObject>> deleteOne(
          String type, String id, String relationship,
          {Map<String, String> headers = const {}}) =>
      send(Request.replaceToOne(RelationshipDocument(One.empty())),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Deletes the [identifiers] from the to-many [relationship] of [type] : [id].
  Future<Response<d.ToManyObject>> deleteMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers = const {}}) =>
      send(Request.deleteFromToMany(RelationshipDocument(Many(identifiers))),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Replaces the to-many [relationship] of [type] : [id] with the [identifiers].
  Future<Response<d.ToManyObject>> replaceMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers = const {}}) =>
      send(Request.replaceToMany(RelationshipDocument(Many(identifiers))),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Adds the [identifiers] to the to-many [relationship] of [type] : [id].
  Future<Response<d.ToManyObject>> addMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers = const {}}) =>
      send(Request.addToMany(RelationshipDocument(Many(identifiers))),
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

  Map<String, Relationship> _rel(
          {Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {}}) =>
      one.map((key, value) => MapEntry(key, One.fromNullable(value)))
        ..addAll(many.map((key, value) => MapEntry(key, Many(value))));

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
