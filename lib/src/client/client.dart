import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/document.dart';
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/nullable.dart';

typedef Document ResponseParser(Object j);

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
  Future<Response<ResourceObjectCollection>> fetchCollection(Uri uri,
          {Map<String, String> headers}) =>
      _get(Document.parseResourceObjectCollection, uri, headers);

  /// Fetches a single resource
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<ResourceObject>> fetchResource(Uri uri,
          {Map<String, String> headers}) =>
      _get(Document.parseResourceObject, uri, headers);

  /// Fetches a to-one relationship
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<IdentifierObject>> fetchToOne(Uri uri,
          {Map<String, String> headers}) =>
      _get(nullable(Relationship.parseToOne), uri, headers);

  /// Fetches a to-many relationship
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<IdentifierObjectCollection>> fetchToMany(Uri uri,
          {Map<String, String> headers}) =>
      _get(Relationship.parseToMany, uri, headers);

  /// Fetches a to-one or to-many relationship.
  /// The actual type of the relationship can be determined afterwards.
  /// Use [headers] to pass extra HTTP headers.
  Future<Response<ResourceLinkage>> fetchRelationship(Uri uri,
          {Map<String, String> headers}) =>
      _get(Relationship.parse, uri, headers);

  /// Creates a new resource. The resource will be added to a collection
  /// according to its type.
  ///
  /// https://jsonapi.org/format/#crud-creating
  Future<Response<ResourceObject>> createResource(Uri uri, Resource resource,
          {Map<String, String> headers}) =>
      _post(Document.parseResourceObject, uri,
          Document(ResourceObject.fromResource(resource)), headers);

  /// Deletes the resource.
  ///
  /// https://jsonapi.org/format/#crud-deleting
  Future<Response> deleteResource(Uri uri, {Map<String, String> headers}) =>
      _delete(Document.parseMeta, uri, headers);

  /// Updates the resource via PATCH request.
  ///
  /// https://jsonapi.org/format/#crud-updating
  Future<Response<ResourceObject>> updateResource(Uri uri, Resource resource,
          {Map<String, String> headers}) =>
      _patch(Document.parseResourceObject, uri,
          Document(ResourceObject.fromResource(resource)), headers);

  /// Updates a to-one relationship via PATCH request
  ///
  /// https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<Response<IdentifierObject>> replaceToOne(Uri uri, Identifier id,
          {Map<String, String> headers}) =>
      _patch(Relationship.parseToOne, uri,
          Relationship(IdentifierObject.fromIdentifier(id)), headers);

  /// Removes a to-one relationship. This is equivalent to calling [replaceToOne]
  /// with id = null.
  Future<Response<IdentifierObject>> removeToOne(Uri uri,
          {Map<String, String> headers}) =>
      replaceToOne(uri, null, headers: headers);

  /// Replaces a to-many relationship with the given set of [ids].
  ///
  /// The server MUST either completely replace every member of the relationship,
  /// return an appropriate error response if some resources can not be found or accessed,
  /// or return a 403 Forbidden response if complete replacement is not allowed by the server.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response<IdentifierObjectCollection>> replaceToMany(
          Uri uri, List<Identifier> ids, {Map<String, String> headers}) =>
      _patch(
          Relationship.parseToMany,
          uri,
          Relationship(IdentifierObjectCollection(
              ids.map(IdentifierObject.fromIdentifier))),
          headers);

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
  Future<Response<IdentifierObjectCollection>> addToMany(
          Uri uri, List<Identifier> ids, {Map<String, String> headers}) =>
      _post(
          Relationship.parseToMany,
          uri,
          Relationship(IdentifierObjectCollection(
              ids.map(IdentifierObject.fromIdentifier))),
          headers);

  Future<Response<D>> _get<D extends PrimaryData>(
          Document<D> parse(Object _), uri, Map<String, String> headers) =>
      _call(
          parse,
          (_) => _.get(uri,
              headers: {}
                ..addAll(headers ?? {})
                ..addAll({'Accept': contentType})));

  Future<Response<D>> _post<D extends PrimaryData>(Document<D> parse(Object _),
          uri, Document document, Map<String, String> headers) =>
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

  Future<Response<D>> _delete<D extends PrimaryData>(Document<D> parse(Object _),
          uri,
          Map<String, String> headers) =>
      _call(
          parse,
          (_) => _.delete(uri,
              headers: {}
                ..addAll(headers ?? {})
                ..addAll({
                  'Accept': contentType,
                })));

  Future<Response<D>> _patch<D extends PrimaryData>(Document<D> parse(Object _),
          uri, Document document, Map<String, String> headers) =>
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

  Future<Response<D>> _call<D extends PrimaryData>(
      Document<D> parse(Object json),
      Future<http.Response> fn(http.Client client)) async {
    final client = _factory();
    try {
      final r = await fn(client);
      if (r.body.isEmpty) {
        return Response(r.statusCode, r.headers);
      }
      final body = json.decode(r.body);

      return Response(r.statusCode, r.headers, document: nullable(parse)(body));
    } finally {
      client.close();
    }
  }
}
