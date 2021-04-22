import 'package:json_api/http.dart';

/// A generic JSON:API response.
class Response {
  Response(this.http, this.document);

  /// HTTP response
  final HttpResponse http;

  /// Decoded JSON document
  final Map? document;
}
