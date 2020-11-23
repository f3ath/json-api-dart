import 'package:json_api/http.dart';

/// Converts errors to HTTP responses.
abstract class ErrorConverter {
  Future<HttpResponse /*?*/ > convert(Object error);
}
