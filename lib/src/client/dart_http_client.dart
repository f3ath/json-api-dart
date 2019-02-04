import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/client.dart';
import 'package:json_api/document.dart';

class DartHttpClient implements Client {
  static const contentType = 'application/vnd.api+json';

  final HttpClientFactory _factory;

  DartHttpClient({HttpClientFactory factory})
      : _factory = factory ?? (() => http.Client());

  Future<Response<CollectionDocument>> fetchCollection(Uri uri,
      {Map<String, String> headers}) {
    return _get((_) => CollectionDocument.fromJson(_), uri, headers);
  }

  Future<Response<ResourceDocument>> fetchResource(Uri uri,
      {Map<String, String> headers}) {
    return _get((_) => ResourceDocument.fromJson(_), uri, headers);
  }

  Future<Response<ToOne>> fetchToOne(Uri uri, {Map<String, String> headers}) {
    return _get((_) => ToOne.fromJson(_), uri, headers);
  }

  Future<Response<ToMany>> fetchToMany(Uri uri, {Map<String, String> headers}) {
    return _get((_) => ToMany.fromJson(_), uri, headers);
  }

  Future<Response<ResourceDocument>> createResource(Uri uri, Resource r,
          {Map<String, String> headers}) =>
      _post((_) => ResourceDocument.fromJson(_), uri, ResourceDocument(r),
          headers);

  Future<Response<ToMany>> addToMany(Uri uri, Iterable<Identifier> ids,
          {Map<String, String> headers}) =>
      _post((_) => ToMany.fromJson(_), uri, ToMany(ids), headers);

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
      return Response(r.statusCode, r.body, r.headers, parse);
    } finally {
      client.close();
    }
  }
}

typedef http.Client HttpClientFactory();
