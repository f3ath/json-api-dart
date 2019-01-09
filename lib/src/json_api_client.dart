import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/src/response.dart';
import 'package:json_api_document/json_api_document.dart';

/// JSON:API client
///
/// The client is based on top of Dart's [http.Client] class. To use a custom
/// client, provide your own [clientFactory].
class JsonApiClient {
  JsonApiClient({
    this.baseUrl = '',
    ClientFactory clientFactory,
    Map<String, String> defaultHeaders = const {},
  })  : clientFactory = clientFactory ?? (() => http.Client()),
        defaultHeaders = Map.unmodifiable({}
          ..addAll(defaultHeaders)
          ..['Accept'] = Document.mediaType);

  final String baseUrl;
  final ClientFactory clientFactory;
  final Map<String, String> defaultHeaders;
  final api = Api('1.0');

  /// Fetches a [Document] containing resource(s) from the given [url].
  /// Pass a [Map] of [headers] to add extra headers to the request.
  ///
  /// More details: https://jsonapi.org/format/#fetching-resources
  Future<Response> fetchResource(String url,
          {Map<String, String> headers = const {}}) async =>
      Response(await _exec((_) => _.get(_url(url), headers: _headers(headers))),
          preferResource: true);

  /// Fetches a [Document] containing identifier(s) from the given [url].
  /// Pass a [Map] of [headers] to add extra headers to the request.
  ///
  /// More details: https://jsonapi.org/format/#fetching-relationships
  Future<Response> fetchRelationship(String url,
          {Map<String, String> headers = const {}}) async =>
      Response(
          await _exec((_) => _.get(_url(url), headers: _headers(headers))));

  /// Creates a new [resource] sending a POST request to the [url].
  /// Pass a [Map] of [headers] to add extra headers to the request.
  ///
  /// More details: https://jsonapi.org/format/#crud-creating
  Future<Response> createResource(String url, Resource resource,
          {Map<String, String> headers = const {}}) async =>
      Response(
          await _exec((_) => _.post(_url(url),
              body: json.encode(DataDocument.fromResource(resource, api: api)),
              headers: _headers(headers, withContentType: true))),
          preferResource: true);

  /// Deletes the resource sending a DELETE request to the [url].
  /// Pass a [Map] of [headers] to add extra headers to the request.
  ///
  /// More details: https://jsonapi.org/format/#crud-deleting
  Future<Response> deleteResource(String url,
          {Map<String, String> headers = const {}}) async =>
      Response(
          await _exec((_) => _.delete(_url(url), headers: _headers(headers))));

  /// Updates the [resource] sending a PATCH request to the [url].
  /// Pass a [Map] of [headers] to add extra headers to the request.
  ///
  /// More details: https://jsonapi.org/format/#crud-updating
  Future<Response> updateResource(String url, Resource resource,
          {Map<String, String> headers = const {}}) async =>
      Response(
          await _exec((_) => _.patch(_url(url),
              body: json.encode(DataDocument.fromResource(resource, api: api)),
              headers: _headers(headers, withContentType: true))),
          preferResource: true);

  /// Creates or updates a to-one relationship sending a corresponding
  /// [identifier] via PATCH request to the [url].
  /// Pass a [Map] of [headers] to add extra headers to the request.
  ///
  /// More details: https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<Response> setToOne(String url, Identifier identifier,
          {Map<String, String> headers = const {}}) async =>
      Response(await _exec((_) => _.patch(_url(url),
          body: json.encode(DataDocument.fromIdentifier(identifier, api: api)),
          headers: _headers(headers, withContentType: true))));

  /// Removes a to-one relationship sending PATCH request with "null" data
  /// to the [url].
  /// Pass a [Map] of [headers] to add extra headers to the request.
  ///
  /// More details: https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<Response> deleteToOne(String url,
          {Map<String, String> headers = const {}}) async =>
      Response(await _exec((_) => _.patch(_url(url),
          body: json.encode(DataDocument.fromNull(api: api)),
          headers: _headers(headers, withContentType: true))));

  /// Updates a to-many relationship sending the
  /// [identifiers] via PATCH request to the [url].
  /// Pass a [Map] of [headers] to add extra headers to the request.
  ///
  /// More details: https://jsonapi.org/format/#crud-updating-to-many-relationships
  setToMany(String url, List<Identifier> identifiers,
          {Map<String, String> headers = const {}}) async =>
      Response(await _exec((_) => _.patch(_url(url),
          body: json
              .encode(DataDocument.fromIdentifierList(identifiers, api: api)),
          headers: _headers(headers, withContentType: true))));

  String _url(String url) => '${baseUrl}${url}';

  Map<String, String> _headers(Map<String, String> headers,
      {bool withContentType = false}) {
    final h = <String, String>{}..addAll(defaultHeaders)..addAll(headers);
    if (withContentType) h['Content-Type'] = Document.mediaType;
    return h;
  }

  Future<http.Response> _exec(
      Future<http.Response> fn(http.Client client)) async {
    final client = clientFactory();
    try {
      return await fn(client);
    } finally {
      client.close();
    }
  }
}

typedef http.Client ClientFactory();
