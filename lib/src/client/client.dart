import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/client/status_code.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/resource.dart';
import 'package:json_api/src/document/collection_document.dart';
import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/error_document.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_document.dart';
import 'package:json_api/src/document/resource_object.dart';

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
  Future<Response<ResourceDocument>> createResource(Uri uri, Resource resource,
          {Map<String, String> headers}) =>
      _post(ResourceDocument.fromJson, uri,
          ResourceDocument(ResourceObject.fromResource(resource)), headers);

//  /// Adds the [identifiers] to a to-many relationship identified by [uri]
//  Future<Response<ToMany>> addToMany(Uri uri, Iterable<Identifier> identifiers,
//          {Map<String, String> headers}) =>
//      _post(ToMany.fromJson, uri,
//          ToMany(identifiers.map(IdentifierObject.fromIdentifier)), headers);
//
//  Future<Response<ResourceDocument>> updateResource(Uri uri, Resource resource,
//          {Map<String, String> headers}) async =>
//      _patch(
//          ResourceDocument.fromJson,
//          uri,
//          ResourceDocument(ResourceObject(resource.type, resource.id,
//              attributes: resource.attributes)),
//          headers);

  Future<Response<D>> _get<D extends Document>(
          ResponseParser<D> parse, uri, Map<String, String> headers) =>
      _call(
          parse,
          (_) => _.get(uri,
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

//  Future<Response<D>> _patch<D extends Document>(ResponseParser<D> parse, uri,
//          Document document, Map<String, String> headers) =>
//      _call(
//          parse,
//          (_) => _.patch(uri,
//              body: json.encode(document),
//              headers: {}
//                ..addAll(headers ?? {})
//                ..addAll({
//                  'Accept': contentType,
//                  'Content-Type': contentType,
//                })));

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
