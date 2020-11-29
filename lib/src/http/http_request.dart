import 'package:json_api/src/http/http_message.dart';

/// The request which is sent by the client and received by the server
class HttpRequest extends HttpMessage {
  HttpRequest(String method, this.uri, {String body = ''})
      : method = method.toLowerCase(),
        super(body);

  /// Requested URI
  final Uri uri;

  /// Request method, lowercase
  final String method;

  bool get isGet => method == 'get';

  bool get isPost => method == 'post';

  bool get isDelete => method == 'delete';

  bool get isPatch => method == 'patch';

  bool get isOptions => method == 'options';
}
