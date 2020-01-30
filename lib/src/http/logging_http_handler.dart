import 'package:json_api/src/http/http_handler.dart';
import 'package:json_api/src/http/http_request.dart';
import 'package:json_api/src/http/http_response.dart';

/// A wrapper over [HttpHandler] which allows logging
class LoggingHttpHandler implements HttpHandler {
  /// The wrapped handler
  final HttpHandler wrapped;

  /// This function will be called before the request is sent
  final void Function(HttpRequest) onRequest;

  /// This function will be called after the response is received
  final void Function(HttpResponse) onResponse;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    onRequest?.call(request);
    final response = await wrapped(request);
    onResponse?.call(response);
    return response;
  }

  LoggingHttpHandler(this.wrapped, {this.onRequest, this.onResponse});
}
