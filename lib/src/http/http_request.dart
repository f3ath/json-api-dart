import 'package:json_api/src/http/headers.dart';

/// The request which is sent by the client and received by the server
class HttpRequest {
  HttpRequest(String method, this.uri, {this.body = ''})
      : method = method.toLowerCase();

  /// Requested URI
  final Uri uri;

  /// Request method, lowercase
  final String method;

  /// Request body
  final String body;

  /// Request headers. Lowercase keys
  final headers = Headers();

  bool get isGet => method == 'get';

  bool get isPost => method == 'post';

  bool get isDelete => method == 'delete';

  bool get isPatch => method == 'patch';

  bool get isOptions => method == 'options';
}
