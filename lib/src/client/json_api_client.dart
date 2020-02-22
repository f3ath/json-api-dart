import 'dart:async';
import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/client/status_code.dart';

/// The JSON:API Client.
class JsonApiClient {
  /// Creates an instance of JSON:API client.
  /// Provide instances of [HttpHandler] (e.g. [DartHttp])
  JsonApiClient(this._httpHandler);

  final HttpHandler _httpHandler;

  /// Fetches a resource collection at the [uri].
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<Response<ResourceCollectionData>> fetchCollectionAt(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ResourceCollectionData.fromJson);

  /// Fetches a single resource at the [uri].
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<Response<ResourceData>> fetchResourceAt(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ResourceData.fromJson);

  /// Fetches a to-one relationship
  /// Use [headers] to pass extra HTTP headers.
  /// Use [queryParameters] to specify extra request parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<Response<ToOne>> fetchToOneAt(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ToOne.fromJson);

  /// Fetches a to-many relationship
  /// Use [headers] to pass extra HTTP headers.
  /// Use [queryParameters] to specify extra request parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<Response<ToMany>> fetchToManyAt(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ToMany.fromJson);

  /// Fetches a to-one or to-many relationship.
  /// The actual type of the relationship can be determined afterwards.
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<Response<Relationship>> fetchRelationshipAt(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), Relationship.fromJson);

  /// Creates a new resource. The resource will be added to a collection
  /// according to its type.
  ///
  /// https://jsonapi.org/format/#crud-creating
  Future<Response<ResourceData>> createResourceAt(Uri uri, Resource resource,
          {Map<String, String> headers}) =>
      _call(_post(uri, headers, _resourceDoc(resource)), ResourceData.fromJson);

  /// Deletes the resource.
  ///
  /// https://jsonapi.org/format/#crud-deleting
  Future<Response> deleteResourceAt(Uri uri, {Map<String, String> headers}) =>
      _call(_delete(uri, headers), null);

  /// Updates the resource via PATCH query.
  ///
  /// https://jsonapi.org/format/#crud-updating
  Future<Response<ResourceData>> updateResourceAt(Uri uri, Resource resource,
          {Map<String, String> headers}) =>
      _call(
          _patch(uri, headers, _resourceDoc(resource)), ResourceData.fromJson);

  /// Updates a to-one relationship via PATCH query
  ///
  /// https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<Response<ToOne>> replaceToOneAt(Uri uri, Identifier identifier,
          {Map<String, String> headers}) =>
      _call(_patch(uri, headers, _toOneDoc(identifier)), ToOne.fromJson);

  /// Removes a to-one relationship. This is equivalent to calling [replaceToOneAt]
  /// with id = null.
  Future<Response<ToOne>> deleteToOneAt(Uri uri,
          {Map<String, String> headers}) =>
      replaceToOneAt(uri, null, headers: headers);

  /// Removes the [identifiers] from the to-many relationship.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response<ToMany>> deleteFromToManyAt(
          Uri uri, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _call(_deleteWithBody(uri, headers, _toManyDoc(identifiers)),
          ToMany.fromJson);

  /// Replaces a to-many relationship with the given set of [identifiers].
  ///
  /// The server MUST either completely replace every member of the relationship,
  /// return an appropriate error response if some resources can not be found or accessed,
  /// or return a 403 Forbidden response if complete replacement is not allowed by the server.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response<ToMany>> replaceToManyAt(
          Uri uri, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _call(_patch(uri, headers, _toManyDoc(identifiers)), ToMany.fromJson);

  /// Adds the given set of [identifiers] to a to-many relationship.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response<ToMany>> addToRelationshipAt(
          Uri uri, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _call(_post(uri, headers, _toManyDoc(identifiers)), ToMany.fromJson);

  final _api = Api(version: '1.0');

  Document<ResourceData> _resourceDoc(Resource resource) =>
      Document(ResourceData.fromResource(resource), api: _api);

  Document<ToMany> _toManyDoc(Iterable<Identifier> identifiers) =>
      Document(ToMany.fromIdentifiers(identifiers), api: _api);

  Document<ToOne> _toOneDoc(Identifier identifier) =>
      Document(ToOne.fromIdentifier(identifier), api: _api);

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

  Future<Response<D>> _call<D extends PrimaryData>(
      HttpRequest request, D Function(Object _) decodePrimaryData) async {
    final response = await _httpHandler(request);
    final document = response.body.isEmpty ? null : jsonDecode(response.body);
    if (document == null) {
      return Response(response.statusCode, response.headers);
    }
    if (StatusCode(response.statusCode).isPending) {
      return Response(response.statusCode, response.headers,
          asyncDocument: document == null
              ? null
              : Document.fromJson(document, ResourceData.fromJson));
    }
    return Response(response.statusCode, response.headers,
        document: document == null
            ? null
            : Document.fromJson(document, decodePrimaryData));
  }
}
