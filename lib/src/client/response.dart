import 'dart:convert';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart' as d;
import 'package:json_api/http.dart';
import 'package:json_api/src/client/status_code.dart';

/// A JSON:API response
class Response<D extends d.PrimaryData> {
  Response(this.http, this._decoder);

  final d.PrimaryDataDecoder<D> _decoder;

  /// The HTTP response.
  final HttpResponse http;

  /// Returns the Document parsed from the response body.
  /// Throws a [StateError] if the HTTP response contains empty body.
  /// Throws a [DocumentException] if the received document structure is invalid.
  /// Throws a [FormatException] if the received JSON is invalid.
  d.Document<D> decodeDocument() {
    if (http.body.isEmpty) throw StateError('The HTTP response has empty body');
    return d.Document.fromJson(jsonDecode(http.body), _decoder);
  }

  /// Returns the async Document parsed from the response body.
  /// Throws a [StateError] if the HTTP response contains empty body.
  /// Throws a [DocumentException] if the received document structure is invalid.
  /// Throws a [FormatException] if the received JSON is invalid.
  d.Document<d.ResourceData> decodeAsyncDocument() {
    if (http.body.isEmpty) throw StateError('The HTTP response has empty body');
    return d.Document.fromJson(jsonDecode(http.body), d.ResourceData.fromJson);
  }

  /// Was the query successful?
  ///
  /// For pending (202 Accepted) requests both [isSuccessful] and [isFailed]
  /// are always false.
  bool get isSuccessful => StatusCode(http.statusCode).isSuccessful;

  /// This property is an equivalent of `202 Accepted` HTTP status.
  /// It indicates that the query is accepted but not finished yet (e.g. queued).
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  bool get isAsync => StatusCode(http.statusCode).isPending;

  /// Any non 2** status code is considered a failed operation.
  /// For failed requests, [document] is expected to contain [ErrorDocument]
  bool get isFailed => StatusCode(http.statusCode).isFailed;
}
