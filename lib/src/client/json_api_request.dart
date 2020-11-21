import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';

/// An abstract request consumed by the client
abstract class JsonApiRequest<T> {
  /// HTTP method
  String get method;

  /// The outbound document. Nullable.
  Object /*?*/ get document;

  /// Any extra headers.
  Map<String, String> get headers;

  /// Returns the request URI
  Uri uri(UriFactory uriFactory);

  /// Converts the HTTP response to the response object
  T response(HttpResponse response);
}
