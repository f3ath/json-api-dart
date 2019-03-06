import 'package:json_api/src/client/document.dart';
import 'package:json_api/src/client/status_code.dart';

/// A response returned by JSON:API cars_server
class Response<Data extends PrimaryData> {
  /// HTTP status code
  final int status;

  /// Document parsed from the response body.
  /// May be null.
  final Document<Data> document;

  /// Headers returned by the server.
  final Map<String, String> headers;

  Response(this.status, this.headers, this.document) {
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
