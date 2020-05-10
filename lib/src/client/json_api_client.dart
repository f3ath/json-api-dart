import 'package:json_api/client.dart';
import 'package:json_api/document.dart' as d;
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';

/// The JSON:API client
class JsonApiClient {
  JsonApiClient(this._http, this._uri);

  final HttpHandler _http;
  final UriFactory _uri;

  /// Fetches a primary resource collection by [type].
  Future<FetchCollectionResponse> fetchCollection(String type,
          {Map<String, String> headers,
          Iterable<String> include = const []}) async =>
      FetchCollectionResponse.fromHttp(await _call(
          Request.fetchCollection(include: include),
          _uri.collection(type),
          headers));

  /// Fetches a related resource collection by [type], [id], [relationship].
  Future<FetchCollectionResponse> fetchRelatedCollection(
          String type, String id, String relationship,
          {Map<String, String> headers,
          Iterable<String> include = const []}) async =>
      FetchCollectionResponse.fromHttp(await _call(
          Request.fetchCollection(include: include),
          _uri.related(type, id, relationship),
          headers));

  /// Fetches a primary resource by [type] and [id].
  Future<FetchPrimaryResourceResponse> fetchResource(String type, String id,
          {Map<String, String> headers,
          Iterable<String> include = const []}) async =>
      FetchPrimaryResourceResponse.fromHttp(await _call(
          Request.fetchResource(include: include),
          _uri.resource(type, id),
          headers));

  /// Fetches a related resource by [type], [id], [relationship].
  Future<FetchRelatedResourceResponse> fetchRelatedResource(
          String type, String id, String relationship,
          {Map<String, String> headers,
          Iterable<String> include = const []}) async =>
      FetchRelatedResourceResponse.fromHttp(await _call(
          Request.fetchResource(include: include),
          _uri.related(type, id, relationship),
          headers));

  /// Fetches a to-one relationship by [type], [id], [relationship].
  Future<Response<d.ToOneObject>> fetchOne(
          String type, String id, String relationship,
          {Map<String, String> headers, Iterable<String> include = const []}) =>
      send(Request.fetchOne(include: include),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Fetches a to-many relationship by [type], [id], [relationship].
  Future<Response<d.ToManyObject>> fetchMany(
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
          Map<String, Ref> one = const {},
          Map<String, Iterable<Ref>> many = const {},
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
          Map<String, Ref> one = const {},
          Map<String, Iterable<Ref>> many = const {},
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
          Map<String, Ref> one = const {},
          Map<String, Iterable<Ref>> many = const {},
          Map<String, String> headers = const {}}) =>
      send(
          Request.updateResource(type, id,
              attributes: attributes, one: one, many: many),
          _uri.resource(type, id),
          headers: headers);

  /// Replaces the to-one [relationship] of [type] : [id].
  Future<Response<d.ToOneObject>> replaceOne(
          String type, String id, String relationship, Ref identifier,
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
          String relationship, Iterable<Ref> identifiers,
          {Map<String, String> headers = const {}}) =>
      send(Request.deleteMany(identifiers),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Replaces the to-many [relationship] of [type] : [id] with the [identifiers].
  Future<Response<d.ToManyObject>> replaceMany(String type, String id,
          String relationship, Iterable<Ref> identifiers,
          {Map<String, String> headers = const {}}) =>
      send(Request.replaceMany(identifiers),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Adds the [identifiers] to the to-many [relationship] of [type] : [id].
  Future<Response<d.ToManyObject>> addMany(String type, String id,
          String relationship, Iterable<Ref> identifiers,
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
      Request request, Uri uri, Map<String, String> headers) async {
    final response = await _http.call(_toHttp(request, uri, headers));
    if (StatusCode(response.statusCode).isFailed) {
      throw RequestFailure.decode(response);
    }
    return response;
  }

  HttpRequest _toHttp(Request request, Uri uri, Map<String, String> headers) =>
      HttpRequest(request.method, request.parameters.addToUri(uri),
          body: request.body, headers: {...?headers, ...request.headers});
}
