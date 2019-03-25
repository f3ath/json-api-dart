import 'package:json_api/src/client/status_code.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api_document/document.dart';

/// A response returned by JSON:API client
class Response<Data extends PrimaryData> {
  /// HTTP status code
  final int status;

  /// Document parsed from the response body.
  /// May be null.
  final Document<Data> document;

  /// The document received with `202 Accepted` response (if any)
  /// https://jsonapi.org/recommendations/#asynchronous-processing
  final Document<ResourceData> asyncDocument;

  /// Headers returned by the server.
  final Map<String, String> headers;

  Response(this.status, this.headers, {this.document, this.asyncDocument});

  /// Primary Data from the document (if any)
  Data get data => document.data;

  /// Primary Data from the async document (if any)
  ResourceData get asyncData => asyncDocument.data;

  /// Was the request successful?
  ///
  /// For pending (202 Accepted) requests both [isSuccessful] and [isFailed]
  /// are always false.
  bool get isSuccessful => StatusCode(status).isSuccessful;

  /// This property is an equivalent of `202 Accepted` HTTP status.
  /// It indicates that the request is accepted but not finished yet (e.g. queued).
  /// The [contentLocation] should have a link to the job queue resource and
  /// [asyncData] may contain a queued job resource object.
  ///
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  bool get isAsync => StatusCode(status).isPending;

  /// Any non 2** status code is considered a failed operation.
  /// For failed requests, [document] is expected to contain [ErrorDocument]
  bool get isFailed => StatusCode(status).isFailed;

  /// The `Location` HTTP header value. For `201 Created` responses this property
  /// contains the location of a newly created resource.
  Uri get location => nullable(Uri.parse)(headers['location']);

  /// The `Content-Location` HTTP header value. For `202 Accepted` responses
  /// this property contains the location of the Job Queue resource.
  ///
  /// More details: https://jsonapi.org/recommendations/#asynchronous-processing
  Uri get contentLocation => nullable(Uri.parse)(headers['content-location']);
}
