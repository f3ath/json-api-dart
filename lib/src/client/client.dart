import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/document.dart';
import 'package:json_api/src/client/response.dart';

typedef D ResponseParser<D extends Document>(Object j);

class Client {
  static const contentType = 'application/vnd.api+json';

  final HttpClientFactory _factory;

  Client({HttpClientFactory factory})
      : _factory = factory ?? (() => http.Client());

  Future<Response<CollectionDocument>> fetchCollection(Uri uri,
          {Map<String, String> headers}) =>
      _get(CollectionDocument.fromJson, uri, headers);

  Future<Response<ResourceDocument>> fetchResource(Uri uri,
          {Map<String, String> headers}) =>
      _get(ResourceDocument.fromJson, uri, headers);

  Future<Response<ToOne>> fetchToOne(Uri uri, {Map<String, String> headers}) =>
      _get(ToOne.fromJson, uri, headers);

  Future<Response<ToMany>> fetchToMany(Uri uri,
          {Map<String, String> headers}) =>
      _get(ToMany.fromJson, uri, headers);

  Future<Response<ResourceDocument>> createResource(Uri uri, Resource r,
          {Map<String, String> headers}) =>
      _post(ResourceDocument.fromJson, uri, ResourceDocument(r), headers);

  Future<Response<ToMany>> addToMany(Uri uri, Iterable<Identifier> ids,
          {Map<String, String> headers}) =>
      _post(ToMany.fromJson, uri, ToMany(ids), headers);

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

typedef http.Client HttpClientFactory();
