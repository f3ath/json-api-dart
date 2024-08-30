import 'package:json_api/document.dart';
import 'package:json_api/src/client/response.dart';

/// Thrown when the server returns a non-successful response.
class RequestFailure implements Exception {
  RequestFailure(this.rawResponse) {
    final json = rawResponse.document;
    if (json == null) return;
    final document = InboundDocument(json);
    errors.addAll(document.errors());
    meta.addAll(document.meta());
  }

  /// The raw JSON:API response
  final Response rawResponse;

  /// Error objects returned by the server
  final errors = <ErrorObject>[];

  /// Top-level meta data
  final meta = <String, Object?>{};

  @override
  String toString() =>
      'JSON:API request failed with HTTP status ${rawResponse.httpResponse.statusCode}.';
}
