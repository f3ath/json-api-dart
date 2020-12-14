import 'package:json_api/src/http/http_headers.dart';

class HttpMessage with HttpHeaders {
  HttpMessage(this.body);

  /// Message body
  final String body;
}
