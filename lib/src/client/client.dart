import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/document.dart';
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/client/status_code.dart';
import 'package:json_api/src/document/collection_document.dart';
import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/error_document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/meta_document.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_document.dart';
import 'package:json_api/src/document/resource_object.dart';
import 'package:json_api/src/nullable.dart';

typedef D ResponseParser<D extends Document>(Object j);

typedef http.Client HttpClientFactory();

/// JSON:API client
class JsonApiClient {
  static const contentType = 'application/vnd.api+json';

  final HttpClientFactory _factory;

  /// JSON:API client uses Dart's native Http Client internally.
  /// To customize its behavior you can pass the [factory] function.
  JsonApiClient({HttpClientFactory factory})
      : _factory = factory ?? (() => http.Client());

  /// Fetches a resource collection by sending a GET request to the [uri].
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<CollectionDocument>> fetchCollection(Uri uri,
          {Map<String, String> headers}) =>
      _get(CollectionDocument.fromJson, uri, headers);

  /// Fetches a single resource
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<ResourceDocument>> fetchResource(Uri uri,
          {Map<String, String> headers}) =>
      _get(ResourceDocument.fromJson, uri, headers);

  /// Fetches a to-one relationship
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<ToOne>> fetchToOne(Uri uri, {Map<String, String> headers}) =>
      _get(ToOne.fromJson, uri, headers);

  /// Fetches a to-many relationship
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<ToMany>> fetchToMany(Uri uri,
          {Map<String, String> headers}) =>
      _get(ToMany.fromJson, uri, headers);

  /// Fetches a to-one or to-many relationship.
  /// The actual type of the relationship can be determined afterwards.
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<Relationship>> fetchRelationship(Uri uri,
          {Map<String, String> headers}) =>
      _get(Relationship.fromJson, uri, headers);

  /// Creates a new resource. The resource will be added to a collection
  /// according to its type.
  ///
  /// https://jsonapi.org/format/#crud-creating
  Future<Response<ResourceDocument>> createResource(Uri uri, Resource resource,
          {Map<String, String> headers}) =>
      _post(ResourceDocument.fromJson, uri,
          ResourceDocument(ResourceObject.fromResource(resource)), headers);

  /// Deletes the resource.
  ///
  /// https://jsonapi.org/format/#crud-deleting
  Future<Response<MetaDocument>> deleteResource(Uri uri,
          {Map<String, String> headers}) =>
      _delete(MetaDocument.fromJson, uri, headers);

  /// Updates the resource via PATCH request.
  ///
  /// https://jsonapi.org/format/#crud-updating
  Future<Response<ResourceDocument>> updateResource(Uri uri, Resource resource,
          {Map<String, String> headers}) =>
      _patch(ResourceDocument.fromJson, uri,
          ResourceDocument(ResourceObject.fromResource(resource)), headers);

  /// Updates a to-one relationship via PATCH request
  ///
  /// https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<Response<ToOne>> replaceToOne(Uri uri, Identifier id,
          {Map<String, String> headers}) =>
      _patch(ToOne.fromJson, uri, ToOne(IdentifierObject.fromIdentifier(id)),
          headers);

  /// Removes a to-one relationship. This is equivalent to calling [replaceToOne]
  /// with id = null.
  Future<Response<ToOne>> removeToOne(Uri uri, {Map<String, String> headers}) =>
      _patch(ToOne.fromJson, uri, ToOne(null), headers);

  /// Replaces a to-many relationship with the given set of [ids].
  ///
  /// The server MUST either completely replace every member of the relationship,
  /// return an appropriate error response if some resources can not be found or accessed,
  /// or return a 403 Forbidden response if complete replacement is not allowed by the server.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response<ToMany>> replaceToMany(Uri uri, List<Identifier> ids,
          {Map<String, String> headers}) =>
      _patch(ToMany.fromJson, uri,
          ToMany(ids.map(IdentifierObject.fromIdentifier)), headers);

  /// Adds the given set of [ids] to a to-many relationship.
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
  Future<Response<ToMany>> addToMany(Uri uri, List<Identifier> ids,
          {Map<String, String> headers}) =>
      _post(ToMany.fromJson, uri,
          ToMany(ids.map(IdentifierObject.fromIdentifier)), headers);

  Future<Response<D>> _get<D extends Document>(
          ResponseParser<D> parse, uri, Map<String, String> headers) =>
      _call(
          parse,
          (_) => _.get(uri,
              headers: {}
                ..addAll(headers ?? {})
                ..addAll({'Accept': contentType})));

  Future<Response<D>> _delete<D extends Document>(
          ResponseParser<D> parse, uri, Map<String, String> headers) =>
      _call(
          parse,
          (_) => _.delete(uri,
              headers: {}
                ..addAll(headers ?? {})
                ..addAll({'Accept': contentType})));

  Future<Response<D>> _post<D extends Document>(ResponseParser<D> parse, uri,
          Document document, Map<String, String> headers) =>
      _call(
          parse,
          (_) => _.post(uri,
              body: json.encode(document),
              headers: {}
                ..addAll(headers ?? {})
                ..addAll({
                  'Accept': contentType,
                  'Content-Type': contentType,
                })));

  Future<Response<D>> _patch<D extends Document>(ResponseParser<D> parse, uri,
          Document document, Map<String, String> headers) =>
      _call(
          parse,
          (_) => _.patch(uri,
              body: json.encode(document),
              headers: {}
                ..addAll(headers ?? {})
                ..addAll({
                  'Accept': contentType,
                  'Content-Type': contentType,
                })));

  Future<Response<D>> _call<D extends Document>(ResponseParser<D> parse,
      Future<http.Response> fn(http.Client client)) async {
    final client = _factory();
    try {
      final r = await fn(client);
      final body = r.body.isNotEmpty ? json.decode(r.body) : null;
      final statusCode = StatusCode(r.statusCode);
      if (statusCode.isSuccessful) {
        return Response(r.statusCode, r.headers, nullable(parse)(body));
      }
      return Response.error(
          r.statusCode, r.headers, nullable(ErrorDocument.fromJson)(body));
    } finally {
      client.close();
    }
  }
}
