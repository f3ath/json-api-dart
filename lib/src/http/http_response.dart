import 'package:json_api/src/http/http_message.dart';
import 'package:json_api/src/http/media_type.dart';
import 'package:json_api/src/http/status_code.dart';

/// The response sent by the server and received by the client
class HttpResponse extends HttpMessage {
  HttpResponse(this.statusCode, {String body = ''}) : super(body);

  /// Response status code
  final int statusCode;

  /// True if the body is not empty and the Content-Type
  /// is `application/vnd.api+json`
  bool get hasDocument =>
      body.isNotEmpty &&
      (headers['Content-Type'] ?? '').toLowerCase().startsWith(mediaType);

  /// Returns true if the [statusCode] represents a failure
  bool get isFailed => StatusCode(statusCode).isFailed;
}
