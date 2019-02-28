import 'package:json_api/src/client/status_code.dart';
import 'package:json_api/src/transport/document.dart';
import 'package:json_api/src/transport/error_document.dart';

/// A response returned by JSON:API cars_server
class Response<D extends Document> {
  /// HTTP status code
  final int status;

  /// Document parsed from the response body.
  /// May be null.
  final D document;

  /// Headers returned by the server.
  final Map<String, String> headers;

  /// For unsuccessful responses this field will contain the error document.
  /// May be null.
  final ErrorDocument errorDocument;

  Response(this.status, this.headers, this.document) : errorDocument = null {
    // TODO: Check for null and content-type
  }

  Response.error(this.status, this.headers, this.errorDocument)
      : document = null {
    // TODO: Check for null and content-type
  }

  /// Was the request successful?
  ///
  /// For pending (202 Accepted) requests [isSuccessful] is always false.
  bool get isSuccessful => StatusCode(status).isSuccessful;

  /// Is a request is accepted but not finished yet (e.g. queued) [isPending] is true.
  /// HTTP Status 202 Accepted should be returned for pending requests.
  /// The "Content-Location" header should have a link to the job queue and
  /// [document] should contain a queued job resource object.
  ///
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  bool get isPending => StatusCode(status).isPending;

  /// Any non 2** status code is considered a failed operation.
  /// For failed requests, [document] is expected to contain [ErrorDocument]
  bool get isFailed => StatusCode(status).isFailed;

  String get location => headers['location'];
}
