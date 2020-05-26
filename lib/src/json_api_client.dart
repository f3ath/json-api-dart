import 'package:json_api/json_api.dart';
import 'package:json_api/src/document.dart';
import 'package:json_api_common/http.dart';
import 'package:json_api_common/url_design.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

/// The JSON:API client
class JsonApiClient {
  JsonApiClient(this._http, this._url);

  final HttpHandler _http;
  final UrlDesign _url;

  /// Fetches a primary resource collection by [type].
  Future<FetchCollection> fetchCollection(String type,
          {Map<String, String> headers,
          Iterable<String> include,
          Map<String, List<String>> fields,
          Iterable<String> sort,
          Map<String, String> page,
          Map<String, String> query}) async =>
      FetchCollection(await call(
          JsonApiRequest('GET',
              headers: headers,
              include: include,
              fields: fields,
              sort: sort,
              page: page,
              query: query),
          _url.collection(type)));

  /// Fetches a related resource collection by [type], [id], [relationship].
  Future<FetchCollection> fetchRelatedCollection(
          String type, String id, String relationship,
          {Map<String, String> headers,
          Iterable<String> include,
          Map<String, List<String>> fields,
          Iterable<String> sort,
          Map<String, String> page,
          Map<String, String> query}) async =>
      FetchCollection(await call(
          JsonApiRequest('GET',
              headers: headers,
              include: include,
              fields: fields,
              sort: sort,
              page: page,
              query: query),
          _url.related(type, id, relationship)));

  /// Fetches a primary resource by [type] and [id].
  Future<FetchPrimaryResource> fetchResource(String type, String id,
          {Map<String, String> headers,
          Iterable<String> include,
          Map<String, List<String>> fields,
          Map<String, String> query}) async =>
      FetchPrimaryResource(await call(
          JsonApiRequest('GET',
              headers: headers, include: include, fields: fields, query: query),
          _url.resource(type, id)));

  /// Fetches a related resource by [type], [id], [relationship].
  Future<FetchRelatedResource> fetchRelatedResource(
          String type, String id, String relationship,
          {Map<String, String> headers,
          Iterable<String> include,
          Map<String, List<String>> fields,
          Map<String, String> query}) async =>
      FetchRelatedResource(await call(
          JsonApiRequest('GET',
              headers: headers, include: include, fields: fields, query: query),
          _url.related(type, id, relationship)));

  /// Fetches a relationship by [type], [id], [relationship].
  Future<FetchRelationship<R>> fetchRelationship<R extends Relationship>(
          String type, String id, String relationship,
          {Map<String, String> headers, Map<String, String> query}) async =>
      FetchRelationship(await call(
          JsonApiRequest('GET', headers: headers, query: query),
          _url.relationship(type, id, relationship)));

  /// Creates a new resource on the server.
  /// The server is expected to assign the resource id.
  Future<CreateResource> createNewResource(String type,
          {Map<String, Object> attributes = const {},
          Map<String, String> one = const {},
          Map<String, Iterable<String>> many = const {},
          Map<String, String> headers}) async =>
      CreateResource(await call(
          JsonApiRequest('POST',
              headers: headers,
              document: ResourceDocument(Resource(type,
                  attributes: attributes,
                  relationships: _relationships(one, many)))),
          _url.collection(type)));

  /// Creates a resource on the server.
  /// The server is expected to accept the provided resource id.
  Future<UpdateResource> createResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, String> one = const {},
          Map<String, Iterable<String>> many = const {},
          Map<String, String> headers}) async =>
      UpdateResource(await call(
          JsonApiRequest('POST',
              headers: headers,
              document: _resource(type, id, attributes, one, many)),
          _url.collection(type)));

  /// Deletes the resource by [type] and [id].
  Future<DeleteResource> deleteResource(String type, String id,
          {Map<String, String> headers}) async =>
      DeleteResource(await call(
          JsonApiRequest('DELETE', headers: headers), _url.resource(type, id)));

  /// Updates the resource by [type] and [id].
  Future<UpdateResource> updateResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, String> one = const {},
          Map<String, Iterable<String>> many = const {},
          Map<String, String> headers}) async =>
      UpdateResource(await call(
          JsonApiRequest('PATCH',
              headers: headers,
              document: _resource(type, id, attributes, one, many)),
          _url.resource(type, id)));

  /// Replaces the to-one [relationship] of [type] : [id].
  Future<UpdateRelationship<One>> replaceOne(
          String type, String id, String relationship, Identifier identifier,
          {Map<String, String> headers}) async =>
      UpdateRelationship<One>(await call(
          JsonApiRequest('PATCH', headers: headers, document: One(identifier)),
          _url.relationship(type, id, relationship)));

  /// Deletes the to-one [relationship] of [type] : [id].
  Future<UpdateRelationship<One>> deleteOne(
          String type, String id, String relationship,
          {Map<String, String> headers}) async =>
      UpdateRelationship<One>(await call(
          JsonApiRequest('PATCH', headers: headers, document: One.empty()),
          _url.relationship(type, id, relationship)));

  /// Deletes the [identifiers] from the to-many [relationship] of [type] : [id].
  Future<UpdateRelationship<Many>> deleteMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) async =>
      UpdateRelationship<Many>(await call(
          JsonApiRequest('DELETE',
              headers: headers, document: Many(identifiers)),
          _url.relationship(type, id, relationship)));

  /// Replaces the to-many [relationship] of [type] : [id] with the [identifiers].
  Future<UpdateRelationship<Many>> replaceMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) async =>
      UpdateRelationship<Many>(await call(
          JsonApiRequest('PATCH',
              headers: headers, document: Many(identifiers)),
          _url.relationship(type, id, relationship)));

  /// Adds the [identifiers] to the to-many [relationship] of [type] : [id].
  Future<UpdateRelationship<Many>> addMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers = const {}}) async =>
      UpdateRelationship<Many>(await call(
          JsonApiRequest('POST', headers: headers, document: Many(identifiers)),
          _url.relationship(type, id, relationship)));

  /// Sends the [request] to [uri].
  /// If the response is successful, returns the [HttpResponse].
  /// Otherwise, throws a [RequestFailure].
  Future<HttpResponse> call(JsonApiRequest request, Uri uri) async {
    final response = await _http.call(HttpRequest(
        request.method,
        request.query.isEmpty
            ? uri
            : uri.replace(queryParameters: request.query),
        body: request.body,
        headers: request.headers));
    if (StatusCode(response.statusCode).isFailed) {
      throw RequestFailure.fromHttp(response);
    }
    return response;
  }

  ResourceDocument _resource(
          String type,
          String id,
          Map<String, Object> attributes,
          Map<String, String> one,
          Map<String, Iterable<String>> many) =>
      ResourceDocument(ResourceWithIdentity(type, id,
          attributes: attributes, relationships: _relationships(one, many)));

  Map<String, Relationship> _relationships(
          Map<String, String> one, Map<String, Iterable<String>> many) =>
      {
        ...one.map((key, value) => MapEntry(
            key,
            Maybe(value)
                .filter((_) => _.isNotEmpty)
                .map(Identifier.fromKey)
                .map((_) => One(_))
                .orGet(() => One.empty()))),
        ...many.map(
            (key, value) => MapEntry(key, Many(value.map(Identifier.fromKey))))
      };
}
