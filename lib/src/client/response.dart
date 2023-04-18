import 'package:http_interop/http_interop.dart' as interop;
import 'package:json_api/http.dart';

/// A generic JSON:API response.
class Response {
  Response(this.http, this.document);

  /// HTTP response
  final interop.Response http;

  /// Decoded JSON document
  final Map? document;

  /// Returns true if the [statusCode] represents a failure
  bool get isFailed => StatusCode(http.statusCode).isFailed;
}
