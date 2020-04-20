import 'package:json_api/document.dart';
import 'package:json_api/src/client/status_code.dart';
import 'package:json_api/src/nullable.dart';

/// A response returned by JSON:API client
class Response<D extends PrimaryData> {
  const Response(this.statusCode, this.headers,
      {this.document, this.asyncDocument});

  /// HTTP status code
  final int statusCode;

  /// Document parsed from the response body.
  /// May be null.
  final Document<D> document;

  /// The document received with `202 Accepted` response (if any)
  /// https://jsonapi.org/recommendations/#asynchronous-processing
  final Document<ResourceData> asyncDocument;

  /// Headers returned by the server.
  final Map<String, String> headers;

  /// Primary Data from the document (if any). For unsuccessful operations
  /// this property will be null, the error details may be found in [Document.errors].
  D get data => document?.data;

  /// List of errors (if any) returned by the server in case of an unsuccessful
  /// operation. May be empty. Will be null if the operation was successful.
  List<ErrorObject> get errors => document?.errors;

  /// Primary Data from the async document (if any)
  ResourceData get asyncData => asyncDocument?.data;

  /// Was the query successful?
  ///
  /// For pending (202 Accepted) requests both [isSuccessful] and [isFailed]
  /// are always false.
  bool get isSuccessful => StatusCode(statusCode).isSuccessful;

  /// This property is an equivalent of `202 Accepted` HTTP status.
  /// It indicates that the query is accepted but not finished yet (e.g. queued).
  /// If the response is async, the [data] and [document] properties will be null
  /// and the returned primary data (usually representing a job queue) will be
  /// in [asyncData] and [asyncDocument].
  /// The [contentLocation] will point to the job queue resource.
  /// You can fetch the job queue resource periodically and check the type of
  /// the returned resource. Once the operation is complete, the request will
  /// return the created resource.
  ///
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  bool get isAsync => StatusCode(statusCode).isPending;

  /// Any non 2** status code is considered a failed operation.
  /// For failed requests, [document] is expected to contain [ErrorDocument]
  bool get isFailed => StatusCode(statusCode).isFailed;

  /// The `Location` HTTP header value. For `201 Created` responses this property
  /// contains the location of a newly created resource.
  Uri get location => nullable(Uri.parse)(headers['location']);

  /// The `Content-Location` HTTP header value. For `202 Accepted` responses
  /// this property contains the location of the Job Queue resource.
  ///
  /// More details: https://jsonapi.org/recommendations/#asynchronous-processing
  Uri get contentLocation => nullable(Uri.parse)(headers['content-location']);
}
