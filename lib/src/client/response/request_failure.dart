import 'package:http_interop/http_interop.dart' as interop;
import 'package:json_api/document.dart';

/// Thrown when the server returns a non-successful response.
class RequestFailure implements Exception {
  RequestFailure(this.http, Map? document) {
    if (document != null) {
      errors.addAll(InboundDocument(document).errors());
      meta.addAll(InboundDocument(document).meta());
    }
  }

  final interop.Response http;

  /// Error objects returned by the server
  final errors = <ErrorObject>[];

  /// Top-level meta data
  final meta = <String, Object?>{};

  @override
  String toString() =>
      'JSON:API request failed with HTTP status ${http.statusCode}.';
}
