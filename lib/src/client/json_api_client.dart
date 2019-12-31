import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/client/client_document_factory.dart';
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/client/status_code.dart';

/// The JSON:API Client.
///
/// [JsonApiClient] works on top of Dart's built-in HTTP client.
/// ```dart
/// import 'package:http/http.dart';
/// import 'package:json_api/client.dart';
///
/// void main() async {
///   final httpClient = Client();
///   final jsonApiClient = JsonApiClient(httpClient);
///   final url = Uri.parse('http://localhost:8080/companies/2');
///   final response = await jsonApiClient.fetchCollection(url);
///   httpClient.close(); // Don't forget to close the http client
///   print('The collection page size is ${response.data.collection.length}');
///   final resource = response.data.unwrap().first;
///   print('The last element is ${resource}');
///   resource.attributes.forEach((k, v) => print('Attribute $k is $v'));
/// }
/// ```
class JsonApiClient {
  final http.Client httpClient;
  final OnHttpCall _onHttpCall;
  final ClientDocumentFactory _factory;

  /// Creates an instance of JSON:API client.
  /// You have to create and pass an instance of the [httpClient] yourself.
  /// Do not forget to call [httpClient.close()] when you're done using
  /// the JSON:API client.
  /// The [onHttpCall] hook, if passed, gets called when an http response is
  /// received from the HTTP Client.
  JsonApiClient(this.httpClient,
      {ClientDocumentFactory builder, OnHttpCall onHttpCall})
      : _factory = builder ?? ClientDocumentFactory(),
        _onHttpCall = onHttpCall ?? _doNothing;

  /// Fetches a resource collection by sending a GET query to the [uri].
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<Response<ResourceCollectionData>> fetchCollection(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ResourceCollectionData.fromJson);

  /// Fetches a single resource
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<Response<ResourceData>> fetchResource(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ResourceData.fromJson);

  /// Fetches a to-one relationship
  /// Use [headers] to pass extra HTTP headers.
  /// Use [queryParameters] to specify extra request parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<Response<ToOne>> fetchToOne(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ToOne.fromJson);

  /// Fetches a to-many relationship
  /// Use [headers] to pass extra HTTP headers.
  /// Use [queryParameters] to specify extra request parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<Response<ToMany>> fetchToMany(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ToMany.fromJson);

  /// Fetches a to-one or to-many relationship.
  /// The actual type of the relationship can be determined afterwards.
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<Response<Relationship>> fetchRelationship(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), Relationship.fromJson);

  /// Creates a new resource. The resource will be added to a collection
  /// according to its type.
  ///
  /// https://jsonapi.org/format/#crud-creating
  Future<Response<ResourceData>> createResource(Uri uri, Resource resource,
          {Map<String, String> headers}) =>
      _call(_post(uri, headers, _factory.makeResourceDocument(resource)),
          ResourceData.fromJson);

  /// Deletes the resource.
  ///
  /// https://jsonapi.org/format/#crud-deleting
  Future<Response> deleteResource(Uri uri, {Map<String, String> headers}) =>
      _call(_delete(uri, headers), null);

  /// Updates the resource via PATCH query.
  ///
  /// https://jsonapi.org/format/#crud-updating
  Future<Response<ResourceData>> updateResource(Uri uri, Resource resource,
          {Map<String, String> headers}) =>
      _call(_patch(uri, headers, _factory.makeResourceDocument(resource)),
          ResourceData.fromJson);

  /// Updates a to-one relationship via PATCH query
  ///
  /// https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<Response<ToOne>> replaceToOne(Uri uri, Identifier identifier,
          {Map<String, String> headers}) =>
      _call(_patch(uri, headers, _factory.makeToOneDocument(identifier)),
          ToOne.fromJson);

  /// Removes a to-one relationship. This is equivalent to calling [replaceToOne]
  /// with id = null.
  Future<Response<ToOne>> deleteToOne(Uri uri, {Map<String, String> headers}) =>
      replaceToOne(uri, null, headers: headers);

  /// Replaces a to-many relationship with the given set of [identifiers].
  ///
  /// The server MUST either completely replace every member of the relationship,
  /// return an appropriate error response if some resources can not be found or accessed,
  /// or return a 403 Forbidden response if complete replacement is not allowed by the server.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response<ToMany>> replaceToMany(Uri uri, List<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _call(_patch(uri, headers, _factory.makeToManyDocument(identifiers)),
          ToMany.fromJson);

  /// Adds the given set of [identifiers] to a to-many relationship.
  ///
  /// The server MUST add the specified members to the relationship
  /// unless they are already present.
  /// If a given type and id is already in the relationship, the server MUST NOT add it again.
  ///
  /// Note: This matches the semantics of databases that use foreign keys
  /// for has-many relationships. Document-based storage should check
  /// the has-many relationship before appending to avoid duplicates.
  ///
  /// If all of the specified resources can be added to, or are already present in,
  /// the relationship then the server MUST return a successful response.
  ///
  /// Note: This approach ensures that a query is successful if the server’s state
  /// matches the requested state, and helps avoid pointless race conditions
  /// caused by multiple clients making the same changes to a relationship.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response<ToMany>> addToMany(Uri uri, List<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _call(_post(uri, headers, _factory.makeToManyDocument(identifiers)),
          ToMany.fromJson);

  http.Request _get(Uri uri, Map<String, String> headers,
          QueryParameters queryParameters) =>
      http.Request(
          'GET', (queryParameters ?? QueryParameters({})).addToUri(uri))
        ..headers.addAll({
          ...headers ?? {},
          'Accept': Document.contentType,
        });

  http.Request _post(Uri uri, Map<String, String> headers, Document doc) =>
      http.Request('POST', uri)
        ..headers.addAll({
          ...headers ?? {},
          'Accept': Document.contentType,
          'Content-Type': Document.contentType,
        })
        ..body = json.encode(doc);

  http.Request _delete(Uri uri, Map<String, String> headers) =>
      http.Request('DELETE', uri)
        ..headers.addAll({
          ...headers ?? {},
          'Accept': Document.contentType,
        });

  http.Request _patch(uri, Map<String, String> headers, Document doc) =>
      http.Request('PATCH', uri)
        ..headers.addAll({
          ...headers ?? {},
          'Accept': Document.contentType,
          'Content-Type': Document.contentType,
        })
        ..body = json.encode(doc);

  Future<Response<D>> _call<D extends PrimaryData>(
      http.Request request, D Function(Object _) decodePrimaryData) async {
    final response =
        await http.Response.fromStream(await httpClient.send(request));
    _onHttpCall(request, response);
    if (response.body.isEmpty) {
      return Response(response.statusCode, response.headers);
    }
    final body = json.decode(response.body);
    if (StatusCode(response.statusCode).isPending) {
      return Response(response.statusCode, response.headers,
          asyncDocument: body == null
              ? null
              : Document.fromJson(body, ResourceData.fromJson));
    }
    return Response(response.statusCode, response.headers,
        document:
            body == null ? null : Document.fromJson(body, decodePrimaryData));
  }
}

/// Defines the hook which gets called when the HTTP response is received from
/// the HTTP Client.
typedef OnHttpCall = void Function(
    http.Request request, http.Response response);

void _doNothing(http.Request request, http.Response response) {}
