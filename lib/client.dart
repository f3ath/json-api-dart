import 'dart:convert';

import 'package:json_api/document.dart';

export 'package:json_api/src/client/dart_http_client.dart';

abstract class Client {
  Future<Response<CollectionDocument>> fetchCollection(Uri uri,
      {Map<String, String> headers});

  Future<Response<ResourceDocument>> fetchResource(Uri uri,
      {Map<String, String> headers});

  Future<Response<ToOne>> fetchToOne(Uri uri, {Map<String, String> headers});

  Future<Response<ToMany>> fetchToMany(Uri uri, {Map<String, String> headers});

  Future<Response<ResourceDocument>> createResource(Uri uri, Resource r,
      {Map<String, String> headers});

  Future<Response<ToMany>> addToMany(Uri uri, Iterable<Identifier> ids,
      {Map<String, String> headers});
}

typedef D ResponseParser<D>(Object j);

/// A response of JSON:API server
class Response<D extends Document> {
  /// HTTP status code
  final int status;
  final String body;
  final Map<String, String> headers;
  final ResponseParser _parse;

  Response(this.status, this.body, this.headers, this._parse) {
    // TODO: Check for null and content-type
  }

  /// Document parsed from the response body.
  /// May be null.
  D get document =>
      (isSuccessful && body.isNotEmpty) ? _parse(json.decode(body)) : null;

  /// Was the request successful?
  ///
  /// For pending (202 Accepted) requests [isSuccessful] is always false.
  bool get isSuccessful => status >= 200 && status < 300 && !isPending;

  /// Is a request is accepted but not finished yet (e.g. queued) [isPending] is true.
  /// HTTP Status 202 Accepted should be returned for pending requests.
  /// The "Content-Location" header should have a link to the job queue and
  /// [document] should contain a queued job resource object.
  ///
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  bool get isPending => status == 202;

  /// Any non 2** status code is considered a failed operation.
  /// For failed requests, [document] is expected to contain [ErrorDocument]
  bool get isFailed => !isSuccessful && !isPending;
}
