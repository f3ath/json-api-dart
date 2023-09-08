import 'package:http_interop/http_interop.dart' as http;
import 'package:json_api/http.dart';

/// A generic JSON:API response.
class Response {
  Response(this.httpResponse, this.document);

  /// HTTP response
  final http.Response httpResponse;

  /// Decoded JSON document
  final Map? document;

  /// Returns true if the [statusCode] represents a failure
  bool get isFailed => StatusCode(httpResponse.statusCode).isFailed;
}
