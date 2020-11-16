import 'package:json_api/src/http/http_logger.dart';
import 'package:json_api/src/http/http_request.dart';
import 'package:json_api/src/http/http_response.dart';

class LastValueLogger implements HttpLogger {
  @override
  void onRequest(HttpRequest request) => this.request = request;

  @override
  void onResponse(HttpResponse response) => this.response = response;

  /// Last received response or null.
  HttpResponse /*?*/ response;

  /// Last sent request or null.
  HttpRequest /*?*/ request;
}
