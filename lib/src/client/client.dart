import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/resource.dart';
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/transport/collection_document.dart';
import 'package:json_api/src/transport/document.dart';
import 'package:json_api/src/transport/identifier_envelope.dart';
import 'package:json_api/src/transport/relationship.dart';
import 'package:json_api/src/transport/resource_document.dart';
import 'package:json_api/src/transport/resource_envelope.dart';

typedef D ResponseParser<D extends Document>(Object j);

typedef http.Client HttpClientFactory();

class Client {
  static const contentType = 'application/vnd.api+json';

  final HttpClientFactory _factory;

  Client({HttpClientFactory factory})
      : _factory = factory ?? (() => http.Client());

  /// Fetches a resource collection
  Future<Response<CollectionDocument>> fetchCollection(Uri uri,
          {Map<String, String> headers}) =>
      _get(CollectionDocument.fromJson, uri, headers);

  /// Fetches a single resource
  Future<Response<ResourceDocument>> fetchResource(Uri uri,
          {Map<String, String> headers}) =>
      _get(ResourceDocument.fromJson, uri, headers);

  /// Fetches a to-one relationship
  Future<Response<ToOne>> fetchToOne(Uri uri, {Map<String, String> headers}) =>
      _get(ToOne.fromJson, uri, headers);

  /// Fetches a to-many relationship
  Future<Response<ToMany>> fetchToMany(Uri uri,
          {Map<String, String> headers}) =>
      _get(ToMany.fromJson, uri, headers);

  /// Creates a new resource. The resource will be added to a collection
  /// according to its type.
  Future<Response<ResourceDocument>> createResource(Uri uri, Resource r,
          {Map<String, String> headers}) =>
      _post(
          ResourceDocument.fromJson,
          uri,
          ResourceDocument(
              ResourceEnvelope(r.type, r.id, attributes: r.attributes)),
          headers);

  /// Adds the [identifiers] to a to-many relationship identified by [uri]
  Future<Response<ToMany>> addToMany(Uri uri, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _post(ToMany.fromJson, uri,
          ToMany(identifiers.map(IdentifierEnvelope.fromIdentifier)), headers);

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

  Future<Response<D>> _call<D extends Document>(ResponseParser<D> parse,
      Future<http.Response> fn(http.Client client)) async {
    final client = _factory();
    try {
      final r = await fn(client);
      return Response(r.statusCode,
          r.body.isNotEmpty ? parse(json.decode(r.body)) : null, r.headers);
    } finally {
      client.close();
    }
  }
}
