import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/document.dart';

/// The JSON:API client
class JsonApiClient {
  JsonApiClient(this._http, this._uri);

  final HttpHandler _http;
  final UriFactory _uri;

  /// Fetches a primary resource collection by [type].
  Future<FetchCollectionResponse> fetchCollection(String type,
          {Map<String, String> headers,
          Iterable<String> include = const []}) async =>
      FetchCollectionResponse.fromHttp(await call(
          Request.fetch(include: include), _uri.collection(type), headers));

  /// Fetches a related resource collection by [type], [id], [relationship].
  Future<FetchCollectionResponse> fetchRelatedCollection(
          String type, String id, String relationship,
          {Map<String, String> headers,
          Iterable<String> include = const []}) async =>
      FetchCollectionResponse.fromHttp(await call(
          Request.fetch(include: include),
          _uri.related(type, id, relationship),
          headers));

  /// Fetches a primary resource by [type] and [id].
  Future<FetchPrimaryResourceResponse> fetchResource(String type, String id,
          {Map<String, String> headers,
          Iterable<String> include = const []}) async =>
      FetchPrimaryResourceResponse.fromHttp(await call(
          Request.fetch(include: include), _uri.resource(type, id), headers));

  /// Fetches a related resource by [type], [id], [relationship].
  Future<FetchRelatedResourceResponse> fetchRelatedResource(
          String type, String id, String relationship,
          {Map<String, String> headers,
          Iterable<String> include = const []}) async =>
      FetchRelatedResourceResponse.fromHttp(await call(
          Request.fetch(include: include),
          _uri.related(type, id, relationship),
          headers));

  /// Fetches a relationship by [type], [id], [relationship].
  Future<FetchRelationshipResponse<R>>
      fetchRelationship<R extends Relationship>(
              String type, String id, String relationship,
              {Map<String, String> headers = const {}}) async =>
          FetchRelationshipResponse.fromHttp<R>(await call(Request.fetch(),
              _uri.relationship(type, id, relationship), headers));

  /// Creates a new [resource] on the server.
  /// The server is expected to assign the resource id.
  Future<CreateResourceResponse> createNewResource(String type,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {},
          Map<String, String> headers = const {}}) async =>
      CreateResourceResponse.fromHttp(await call(
          Request.createNewResource(type,
              attributes: attributes, one: one, many: many),
          _uri.collection(type),
          headers));

  /// Creates a new [resource] on the server.
  /// The server is expected to accept the provided resource id.
  Future<ResourceResponse> createResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {},
          Map<String, String> headers = const {}}) async =>
      ResourceResponse.fromHttp(await call(
          Request.createResource(type, id,
              attributes: attributes, one: one, many: many),
          _uri.collection(type),
          headers));

  /// Deletes the resource by [type] and [id].
  Future<DeleteResourceResponse> deleteResource(String type, String id,
          {Map<String, String> headers = const {}}) async =>
      DeleteResourceResponse.fromHttp(await call(
          Request.deleteResource(), _uri.resource(type, id), headers));

  /// Updates the [resource].
  Future<ResourceResponse> updateResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {},
          Map<String, String> headers = const {}}) async =>
      ResourceResponse.fromHttp(await call(
          Request.updateResource(type, id,
              attributes: attributes, one: one, many: many),
          _uri.resource(type, id),
          headers));

  /// Replaces the to-one [relationship] of [type] : [id].
  Future<RelationshipResponse<One>> replaceOne(
          String type, String id, String relationship, Identifier identifier,
          {Map<String, String> headers = const {}}) async =>
      RelationshipResponse.fromHttp<One>(await call(
          Request.replaceOne(identifier),
          _uri.relationship(type, id, relationship),
          headers));

  /// Deletes the to-one [relationship] of [type] : [id].
  Future<RelationshipResponse<One>> deleteOne(
          String type, String id, String relationship,
          {Map<String, String> headers = const {}}) async =>
      RelationshipResponse.fromHttp<One>(await call(Request.deleteOne(),
          _uri.relationship(type, id, relationship), headers));

  /// Deletes the [identifiers] from the to-many [relationship] of [type] : [id].
  Future<RelationshipResponse<Many>> deleteMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers = const {}}) async =>
      RelationshipResponse.fromHttp<Many>(await call(
          Request.deleteMany(identifiers),
          _uri.relationship(type, id, relationship),
          headers));

  /// Replaces the to-many [relationship] of [type] : [id] with the [identifiers].
  Future<RelationshipResponse<Many>> replaceMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers = const {}}) async =>
      RelationshipResponse.fromHttp<Many>(await call(
          Request.replaceMany(identifiers),
          _uri.relationship(type, id, relationship),
          headers));

  /// Adds the [identifiers] to the to-many [relationship] of [type] : [id].
  Future<RelationshipResponse<Many>> addMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers = const {}}) async =>
      RelationshipResponse.fromHttp<Many>(await call(
          Request.addMany(identifiers),
          _uri.relationship(type, id, relationship),
          headers));

  Future<HttpResponse> call(
      Request request, Uri uri, Map<String, String> headers) async {
    final response = await _http.call(_toHttp(request, uri, headers));
    if (StatusCode(response.statusCode).isFailed) {
      throw RequestFailure.fromHttp(response);
    }
    return response;
  }

  HttpRequest _toHttp(Request request, Uri uri, Map<String, String> headers) =>
      HttpRequest(request.method, request.parameters.addToUri(uri),
          body: request.body, headers: {...?headers, ...request.headers});
}
