import 'package:json_api/src/http/http_headers.dart';

/// HTTP message. Request or Response.
class HttpMessage with HttpHeaders {
  HttpMessage(this.body);

  /// Message body
  final String body;
}
