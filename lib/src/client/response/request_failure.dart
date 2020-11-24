import 'package:json_api/document.dart';
import 'package:json_api/http.dart';

/// Thrown when the server returns a non-successful response.
class RequestFailure implements Exception {
  RequestFailure(this.http, {Iterable<ErrorObject> errors}) {
    this.errors.addAll(errors);
  }

  /// The response itself.
  final HttpResponse http;

  /// JSON:API errors (if any)
  final errors = <ErrorObject>[];

  @override
  String toString() =>
      'JSON:API request failed with HTTP status ${http.statusCode}';
}
