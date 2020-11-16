import 'package:json_api/src/http/http_handler.dart';
import 'package:json_api/src/http/http_logger.dart';
import 'package:json_api/src/http/http_request.dart';
import 'package:json_api/src/http/http_response.dart';

/// A wrapper over [HttpHandler] which allows logging
class LoggingHttpHandler implements HttpHandler {
  LoggingHttpHandler(this._handler, this._logger);

  final HttpHandler _handler;
  final HttpLogger _logger;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    _logger.onRequest(request);
    final response = await _handler(request);
    _logger.onResponse(response);
    return response;
  }
}
