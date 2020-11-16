import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';

abstract class ClientRequest<T> {
  /// HTTP method
  String get method;

  /// The outbound document. Nullable.
  OutboundDocument /*?*/ get document;

  /// Any extra headers.
  Map<String, String> get headers;

  /// Returns the request URI
  Uri uri(TargetMapper<Uri> urls);

  /// Converts the HTTP response to the response object
  T response(HttpResponse response);
}
