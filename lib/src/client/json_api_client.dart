import 'dart:async';
import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/client/json_api_response.dart';
import 'package:json_api/src/client/request_document_factory.dart';
import 'package:json_api/src/client/status_code.dart';

/// The JSON:API Client.
class JsonApiClient {
  /// Fetches a resource collection by sending a GET query to the [uri].
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ResourceCollectionData>> fetchCollection(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ResourceCollectionData.fromJson);

  /// Fetches a single resource
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ResourceData>> fetchResource(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ResourceData.fromJson);

  /// Fetches a to-one relationship
  /// Use [headers] to pass extra HTTP headers.
  /// Use [queryParameters] to specify extra request parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ToOne>> fetchToOne(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ToOne.fromJson);

  /// Fetches a to-many relationship
  /// Use [headers] to pass extra HTTP headers.
  /// Use [queryParameters] to specify extra request parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ToMany>> fetchToMany(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ToMany.fromJson);

  /// Fetches a to-one or to-many relationship.
  /// The actual type of the relationship can be determined afterwards.
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<Relationship>> fetchRelationship(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), Relationship.fromJson);

  /// Creates a new resource. The resource will be added to a collection
  /// according to its type.
  ///
  /// https://jsonapi.org/format/#crud-creating
  Future<JsonApiResponse<ResourceData>> createResource(
          Uri uri, Resource resource, {Map<String, String> headers}) =>
      _call(_post(uri, headers, _factory.resourceDocument(resource)),
          ResourceData.fromJson);

  /// Deletes the resource.
  ///
  /// https://jsonapi.org/format/#crud-deleting
  Future<JsonApiResponse> deleteResource(Uri uri,
          {Map<String, String> headers}) =>
      _call(_delete(uri, headers), null);

  /// Updates the resource via PATCH query.
  ///
  /// https://jsonapi.org/format/#crud-updating
  Future<JsonApiResponse<ResourceData>> updateResource(
          Uri uri, Resource resource, {Map<String, String> headers}) =>
      _call(_patch(uri, headers, _factory.resourceDocument(resource)),
          ResourceData.fromJson);

  /// Updates a to-one relationship via PATCH query
  ///
  /// https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<JsonApiResponse<ToOne>> replaceToOne(Uri uri, Identifier identifier,
          {Map<String, String> headers}) =>
      _call(_patch(uri, headers, _factory.toOneDocument(identifier)),
          ToOne.fromJson);

  /// Removes a to-one relationship. This is equivalent to calling [replaceToOne]
  /// with id = null.
  Future<JsonApiResponse<ToOne>> deleteToOne(Uri uri,
          {Map<String, String> headers}) =>
      replaceToOne(uri, null, headers: headers);

  /// Removes the [identifiers] from the to-many relationship.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<JsonApiResponse<ToMany>> deleteFromToMany(
          Uri uri, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _call(_deleteWithBody(uri, headers, _factory.toManyDocument(identifiers)),
          ToMany.fromJson);

  /// Replaces a to-many relationship with the given set of [identifiers].
  ///
  /// The server MUST either completely replace every member of the relationship,
  /// return an appropriate error response if some resources can not be found or accessed,
  /// or return a 403 Forbidden response if complete replacement is not allowed by the server.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<JsonApiResponse<ToMany>> replaceToMany(
          Uri uri, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _call(_patch(uri, headers, _factory.toManyDocument(identifiers)),
          ToMany.fromJson);

  /// Adds the given set of [identifiers] to a to-many relationship.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<JsonApiResponse<ToMany>> addToRelationship(
          Uri uri, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _call(_post(uri, headers, _factory.toManyDocument(identifiers)),
          ToMany.fromJson);

  /// Creates an instance of JSON:API client.
  /// Pass an instance of DartHttpClient (comes with this package) or
  /// another instance of [HttpHandler].
  /// Use a custom [documentFactory] if you want to build the outgoing
  /// documents in a special way.
  JsonApiClient(this._http, {RequestDocumentFactory documentFactory})
      : _factory = documentFactory ?? RequestDocumentFactory();

  final HttpHandler _http;
  final RequestDocumentFactory _factory;

  HttpRequest _get(Uri uri, Map<String, String> headers,
          QueryParameters queryParameters) =>
      HttpRequest('GET', (queryParameters ?? QueryParameters({})).addToUri(uri),
          headers: {
            ...headers ?? {},
            'Accept': Document.contentType,
          });

  HttpRequest _post(Uri uri, Map<String, String> headers, Document doc) =>
      HttpRequest('POST', uri,
          headers: {
            ...headers ?? {},
            'Accept': Document.contentType,
            'Content-Type': Document.contentType,
          },
          body: jsonEncode(doc));

  HttpRequest _delete(Uri uri, Map<String, String> headers) =>
      HttpRequest('DELETE', uri, headers: {
        ...headers ?? {},
        'Accept': Document.contentType,
      });

  HttpRequest _deleteWithBody(
          Uri uri, Map<String, String> headers, Document doc) =>
      HttpRequest('DELETE', uri,
          headers: {
            ...headers ?? {},
            'Accept': Document.contentType,
            'Content-Type': Document.contentType,
          },
          body: jsonEncode(doc));

  HttpRequest _patch(uri, Map<String, String> headers, Document doc) =>
      HttpRequest('PATCH', uri,
          headers: {
            ...headers ?? {},
            'Accept': Document.contentType,
            'Content-Type': Document.contentType,
          },
          body: jsonEncode(doc));

  Future<JsonApiResponse<D>> _call<D extends PrimaryData>(
      HttpRequest request, D Function(Object _) decodePrimaryData) async {
    final response = await _http(request);
    final document = response.body.isEmpty ? null : jsonDecode(response.body);
    if (document == null) {
      return JsonApiResponse(response.statusCode, response.headers);
    }
    if (StatusCode(response.statusCode).isPending) {
      return JsonApiResponse(response.statusCode, response.headers,
          asyncDocument: document == null
              ? null
              : Document.fromJson(document, ResourceData.fromJson));
    }
    return JsonApiResponse(response.statusCode, response.headers,
        document: document == null
            ? null
            : Document.fromJson(document, decodePrimaryData));
  }
}
