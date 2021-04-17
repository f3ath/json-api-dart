import 'package:json_api/src/http/http_request.dart';
import 'package:json_api/src/http/http_response.dart';

abstract class HttpHandler {
  Future<HttpResponse> handle(HttpRequest request);
}
