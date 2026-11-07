import 'package:http_interop/http_interop.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/client/client.dart';

/// A generic JSON:API request.
class Request(
  /// Creates a new instance if the request with the specified HTTP [method]
  /// and [document].
  /// HTTP method.
  final String method, [

  /// JSON:API document. This object can be of any type as long as it is
  /// encodable by the [PayloadCodec] used in the [Client].
  final Object? document,
]) {
  /// Creates a GET request.
  new get() : this('GET');

  /// Creates a POST request.
  new post([Object? document]) : this('POST', document);

  /// Creates a DELETE request.
  new delete([Object? document]) : this('DELETE', document);

  /// Creates a PATCH request.
  new patch([Object? document]) : this('PATCH', document);

  /// Query parameters.
  final query = Query();

  /// HTTP headers.
  final headers = Headers();
}
