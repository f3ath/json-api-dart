import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/client/status_code.dart';
import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_collection_data.dart';
import 'package:json_api/src/document/resource_data.dart';
import 'package:json_api/src/document/resource_object.dart';
import 'package:json_api/src/nullable.dart';

typedef http.BaseClient HttpClientFactory();

/// JSON:API client
class JsonApiClient {
  static const contentType = 'application/vnd.api+json';

  final HttpClientFactory _createClient;

  /// JSON:API client uses Dart's native [http.Client] internally.
  /// Pass the [factory] parameter to customize or intercept calls to the HTTP client.
  const JsonApiClient({http.BaseClient factory()})
      : _createClient = factory ?? _defaultFactory;

  /// Fetches a resource collection by sending a GET request to the [uri].
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<ResourceCollectionData>> fetchCollection(Uri uri,
          {Map<String, String> headers = const {}}) =>
      _get(ResourceCollectionData.decodeJson, uri, headers);

  /// Fetches a single resource
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<ResourceData>> fetchResource(Uri uri,
          {Map<String, String> headers = const {}}) =>
      _get(ResourceData.decodeJson, uri, headers);

  /// Fetches a to-one relationship
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<ToOne>> fetchToOne(Uri uri,
          {Map<String, String> headers = const {}}) =>
      _get(ToOne.decodeJson, uri, headers);

  /// Fetches a to-many relationship
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<ToMany>> fetchToMany(Uri uri,
          {Map<String, String> headers = const {}}) =>
      _get(ToMany.decodeJson, uri, headers);

  /// Fetches a to-one or to-many relationship.
  /// The actual type of the relationship can be determined afterwards.
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<Relationship>> fetchRelationship(Uri uri,
          {Map<String, String> headers = const {}}) =>
      _get(Relationship.decodeJson, uri, headers);

  /// Creates a new resource. The resource will be added to a collection
  /// according to its type.
  ///
  /// https://jsonapi.org/format/#crud-creating
  Future<Response<ResourceData>> createResource(Uri uri, Resource resource,
          {Map<String, String> headers = const {}}) =>
      _post(ResourceData.decodeJson, uri,
          ResourceData(ResourceObject.fromResource(resource)), headers);

  /// Deletes the resource.
  ///
  /// https://jsonapi.org/format/#crud-deleting
  Future<Response> deleteResource(Uri uri,
          {Map<String, String> headers = const {}}) =>
      _delete(null, uri, headers);

  /// Updates the resource via PATCH request.
  ///
  /// https://jsonapi.org/format/#crud-updating
  Future<Response<ResourceData>> updateResource(Uri uri, Resource resource,
          {Map<String, String> headers = const {}}) =>
      _patch(ResourceData.decodeJson, uri,
          ResourceData(ResourceObject.fromResource(resource)), headers);

  /// Updates a to-one relationship via PATCH request
  ///
  /// https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<Response<ToOne>> replaceToOne(Uri uri, Identifier identifier,
          {Map<String, String> headers = const {}}) =>
      _patch(ToOne.decodeJson, uri,
          ToOne(nullable((_) => IdentifierObject(_))(identifier)), headers);

  /// Removes a to-one relationship. This is equivalent to calling [replaceToOne]
  /// with id = null.
  Future<Response<ToOne>> deleteToOne(Uri uri,
          {Map<String, String> headers = const {}}) =>
      replaceToOne(uri, null, headers: headers);

  /// Replaces a to-many relationship with the given set of [identifiers].
  ///
  /// The server MUST either completely replace every member of the relationship,
  /// return an appropriate error response if some resources can not be found or accessed,
  /// or return a 403 Forbidden response if complete replacement is not allowed by the server.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response<ToMany>> replaceToMany(Uri uri, List<Identifier> identifiers,
          {Map<String, String> headers = const {}}) =>
      _patch(ToMany.decodeJson, uri,
          ToMany(identifiers.map((_) => IdentifierObject(_))), headers);

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
  /// Note: This approach ensures that a request is successful if the server’s state
  /// matches the requested state, and helps avoid pointless race conditions
  /// caused by multiple clients making the same changes to a relationship.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response<ToMany>> addToMany(Uri uri, List<Identifier> identifiers,
          {Map<String, String> headers = const {}}) =>
      _post(ToMany.decodeJson, uri,
          ToMany(identifiers.map((_) => IdentifierObject(_))), headers);

  Future<Response<D>> _get<D extends PrimaryData>(
          D parse(Object _), uri, Map<String, String> headers) =>
      _call(
          parse,
          (_) => _.get(uri, headers: {
                ...headers,
                'Accept': contentType,
              }));

  Future<Response<D>> _post<D extends PrimaryData>(D parse(Object _), uri,
          PrimaryData data, Map<String, String> headers) =>
      _call(
          parse,
          (_) => _.post(uri, body: _body(data), headers: {
                ...headers,
                'Accept': contentType,
                'Content-Type': contentType,
              }));

  Future<Response<D>> _delete<D extends PrimaryData>(
          D parse(Object _), uri, Map<String, String> headers) =>
      _call(
          parse,
          (_) => _.delete(uri, headers: {
                ...headers,
                'Accept': contentType,
              }));

  Future<Response<D>> _patch<D extends PrimaryData>(D parse(Object _), uri,
          PrimaryData data, Map<String, String> headers) =>
      _call(
          parse,
          (_) => _.patch(uri, body: _body(data), headers: {
                ...headers,
                'Accept': contentType,
                'Content-Type': contentType,
              }));

  String _body(PrimaryData data) => json.encode(Document(data));

  Future<Response<D>> _call<D extends PrimaryData>(
      D decodePrimaryData(Object json),
      Future<http.Response> fn(http.Client client)) async {
    final client = _createClient();
    try {
      final response = await fn(client);
      if (response.body.isEmpty) {
        return Response(response.statusCode, response.headers);
      }
      final body = json.decode(response.body);
      if (StatusCode(response.statusCode).isPending) {
        return Response(response.statusCode, response.headers,
            asyncDocument: body == null
                ? null
                : Document.decodeJson(body, ResourceData.decodeJson));
      }
      return Response(response.statusCode, response.headers,
          document: body == null
              ? null
              : Document.decodeJson(body, decodePrimaryData));
    } finally {
      client.close();
    }
  }
}

http.BaseClient _defaultFactory() => http.Client();
