import 'package:json_api/src/http/headers.dart';
import 'package:json_api/src/http/media_type.dart';

/// The response sent by the server and received by the client
class HttpResponse {
  HttpResponse(this.statusCode, {this.body = ''});

  /// Response status code
  final int statusCode;

  /// Response body
  final String body;

  /// Response headers. Lowercase keys
  final headers = Headers();

  /// True for the requests processed asynchronously.
  /// @see https://jsonapi.org/recommendations/#asynchronous-processing).
  bool get isPending => statusCode == 202;

  /// True for successfully processed requests
  bool get isSuccessful => statusCode >= 200 && statusCode < 300 && !isPending;

  /// True for failed requests (i.e. neither successful nor pending)
  bool get isFailed => !isSuccessful && !isPending;

  /// True for 204 No Content responses
  bool get isNoContent => statusCode == 204;

  bool get hasDocument =>
      body.isNotEmpty &&
      (headers['content-type'] ?? '')
          .toLowerCase()
          .startsWith(MediaType.jsonApi);
}
