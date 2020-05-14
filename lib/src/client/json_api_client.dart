import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/document.dart';
import 'package:json_api/src/maybe.dart';

/// The JSON:API client
class JsonApiClient {
  JsonApiClient(this._http, this._uri);

  final HttpHandler _http;
  final UriFactory _uri;

  /// Fetches a primary resource collection by [type].
  Future<FetchCollectionResponse> fetchCollection(String type,
      {Map<String, String> headers, Iterable<String> include}) async {
    final request = JsonApiRequest.get();
    Maybe(headers).ifPresent(request.headers);
    Maybe(include).ifPresent(request.include);
    return FetchCollectionResponse.fromHttp(
        await call(request, _uri.collection(type)));
  }

  /// Fetches a related resource collection by [type], [id], [relationship].
  Future<FetchCollectionResponse> fetchRelatedCollection(
      String type, String id, String relationship,
      {Map<String, String> headers, Iterable<String> include}) async {
    final request = JsonApiRequest.get();
    Maybe(headers).ifPresent(request.headers);
    Maybe(include).ifPresent(request.include);
    return FetchCollectionResponse.fromHttp(
        await call(request, _uri.related(type, id, relationship)));
  }

  /// Fetches a primary resource by [type] and [id].
  Future<FetchPrimaryResourceResponse> fetchResource(String type, String id,
      {Map<String, String> headers, Iterable<String> include}) async {
    final request = JsonApiRequest.get();
    Maybe(headers).ifPresent(request.headers);
    Maybe(include).ifPresent(request.include);
    return FetchPrimaryResourceResponse.fromHttp(
        await call(request, _uri.resource(type, id)));
  }

  /// Fetches a related resource by [type], [id], [relationship].
  Future<FetchRelatedResourceResponse> fetchRelatedResource(
      String type, String id, String relationship,
      {Map<String, String> headers, Iterable<String> include}) async {
    final request = JsonApiRequest.get();
    Maybe(headers).ifPresent(request.headers);
    Maybe(include).ifPresent(request.include);
    return FetchRelatedResourceResponse.fromHttp(
        await call(request, _uri.related(type, id, relationship)));
  }

  /// Fetches a relationship by [type], [id], [relationship].
  Future<FetchRelationshipResponse<R>>
      fetchRelationship<R extends Relationship>(
          String type, String id, String relationship,
          {Map<String, String> headers}) async {
    final request = JsonApiRequest.get();
    Maybe(headers).ifPresent(request.headers);
    return FetchRelationshipResponse.fromHttp<R>(
        await call(request, _uri.relationship(type, id, relationship)));
  }

  /// Creates a new [_resource] on the server.
  /// The server is expected to assign the resource id.
  Future<CreateResourceResponse> createNewResource(String type,
      {Map<String, Object> attributes = const {},
      Map<String, Identifier> one = const {},
      Map<String, Iterable<Identifier>> many = const {},
      Map<String, String> headers}) async {
    final request = JsonApiRequest.post(ResourceDocument(Resource(type,
        attributes: attributes, relationships: _relationships(one, many))));
    Maybe(headers).ifPresent(request.headers);
    return CreateResourceResponse.fromHttp(
        await call(request, _uri.collection(type)));
  }

  /// Creates a new [_resource] on the server.
  /// The server is expected to accept the provided resource id.
  Future<ResourceResponse> createResource(String type, String id,
      {Map<String, Object> attributes = const {},
      Map<String, Identifier> one = const {},
      Map<String, Iterable<Identifier>> many = const {},
      Map<String, String> headers}) async {
    final request = JsonApiRequest.post(ResourceDocument(ResourceWithIdentity(
        type, id,
        attributes: attributes, relationships: _relationships(one, many))));
    Maybe(headers).ifPresent(request.headers);
    return ResourceResponse.fromHttp(
        await call(request, _uri.collection(type)));
  }

  /// Deletes the resource by [type] and [id].
  Future<DeleteResourceResponse> deleteResource(String type, String id,
      {Map<String, String> headers}) async {
    final request = JsonApiRequest.delete();
    Maybe(headers).ifPresent(request.headers);
    return DeleteResourceResponse.fromHttp(
        await call(request, _uri.resource(type, id)));
  }

  /// Updates the [_resource].
  Future<ResourceResponse> updateResource(String type, String id,
      {Map<String, Object> attributes = const {},
      Map<String, Identifier> one = const {},
      Map<String, Iterable<Identifier>> many = const {},
      Map<String, String> headers}) async {
    final request = JsonApiRequest.patch(ResourceDocument(ResourceWithIdentity(
        type, id,
        attributes: attributes, relationships: _relationships(one, many))));
    Maybe(headers).ifPresent(request.headers);
    return ResourceResponse.fromHttp(
        await call(request, _uri.resource(type, id)));
  }

  /// Replaces the to-one [relationship] of [type] : [id].
  Future<RelationshipResponse<One>> replaceOne(
      String type, String id, String relationship, Identifier identifier,
      {Map<String, String> headers}) async {
    final request = JsonApiRequest.patch(One(identifier));
    Maybe(headers).ifPresent(request.headers);
    return RelationshipResponse.fromHttp<One>(
        await call(request, _uri.relationship(type, id, relationship)));
  }

  /// Deletes the to-one [relationship] of [type] : [id].
  Future<RelationshipResponse<One>> deleteOne(
      String type, String id, String relationship,
      {Map<String, String> headers}) async {
    final request = JsonApiRequest.patch(One.empty());
    Maybe(headers).ifPresent(request.headers);
    return RelationshipResponse.fromHttp<One>(
        await call(request, _uri.relationship(type, id, relationship)));
  }

  /// Deletes the [identifiers] from the to-many [relationship] of [type] : [id].
  Future<RelationshipResponse<Many>> deleteMany(String type, String id,
      String relationship, Iterable<Identifier> identifiers,
      {Map<String, String> headers}) async {
    final request = JsonApiRequest.delete(Many(identifiers));
    Maybe(headers).ifPresent(request.headers);
    return RelationshipResponse.fromHttp<Many>(
        await call(request, _uri.relationship(type, id, relationship)));
  }

  /// Replaces the to-many [relationship] of [type] : [id] with the [identifiers].
  Future<RelationshipResponse<Many>> replaceMany(String type, String id,
      String relationship, Iterable<Identifier> identifiers,
      {Map<String, String> headers}) async {
    final request = JsonApiRequest.patch(Many(identifiers));
    Maybe(headers).ifPresent(request.headers);
    return RelationshipResponse.fromHttp<Many>(
        await call(request, _uri.relationship(type, id, relationship)));
  }

  /// Adds the [identifiers] to the to-many [relationship] of [type] : [id].
  Future<RelationshipResponse<Many>> addMany(String type, String id,
      String relationship, Iterable<Identifier> identifiers,
      {Map<String, String> headers = const {}}) async {
    final request = JsonApiRequest.post(Many(identifiers));
    Maybe(headers).ifPresent(request.headers);
    return RelationshipResponse.fromHttp<Many>(
        await call(request, _uri.relationship(type, id, relationship)));
  }

  /// Sends the [request] to [uri].
  /// If the response is successful, returns the [HttpResponse].
  /// Otherwise, throws a [RequestFailure].
  Future<HttpResponse> call(JsonApiRequest request, Uri uri) async {
    final response = await _http.call(request.toHttp(uri));
    if (StatusCode(response.statusCode).isFailed) {
      throw RequestFailure.fromHttp(response);
    }
    return response;
  }
}

class ResourceDocument {
  ResourceDocument(this._resource);

  final Resource _resource;

  Map<String, Object> toJson() => {'data': _resource.toJson()};
}

Map<String, Relationship> _relationships(
        Map<String, Identifier> one, Map<String, Iterable<Identifier>> many) =>
    {
      ...one.map((key, value) => MapEntry(
          key, Maybe(value).map((t) => One(value)).orGet(() => One.empty()))),
      ...many.map((key, value) => MapEntry(key, Many(value)))
    };
