import 'package:json_api/document.dart';
import 'package:json_api/http.dart';

/// Thrown when the server returns a non-successful response.
class RequestFailure implements Exception {
  RequestFailure(this.http, {this.document});

  /// The response itself.
  final HttpResponse http;
  final InboundDocument /*?*/ document;

  @override
  String toString() =>
      'JSON:API request failed with HTTP status ${http.statusCode}';
}
