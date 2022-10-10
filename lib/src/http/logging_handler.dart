import 'package:json_api/src/http/http_handler.dart';
import 'package:json_api/src/http/http_request.dart';
import 'package:json_api/src/http/http_response.dart';

/// A wrapper over [HttpHandler] which allows logging
class LoggingHandler implements HttpHandler {
  LoggingHandler(this.wrapped, {this.onRequest, this.onResponse});

  final HttpHandler wrapped;
  final Function(HttpRequest request)? onRequest;
  final Function(HttpResponse response)? onResponse;

  @override
  Future<HttpResponse> handle(HttpRequest request) async {
    onRequest?.call(request);
    final response = await wrapped.handle(request);
    onResponse?.call(response);
    return response;
  }
}
