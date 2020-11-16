import 'package:json_api/src/http/http_request.dart';
import 'package:json_api/src/http/http_response.dart';

/// A callable class which converts requests to responses
abstract class HttpHandler {
  /// Sends the request over the network and returns the received response
  Future<HttpResponse /*!*/ > call(HttpRequest request);

  /// Creates an instance of [HttpHandler] from a function
  static HttpHandler fromFunction(HttpHandlerFunc f) => _HandlerFromFunction(f);
}

/// This typedef is compatible with [HttpHandler]
typedef HttpHandlerFunc = Future<HttpResponse> Function(HttpRequest request);

class _HandlerFromFunction implements HttpHandler {
  const _HandlerFromFunction(this._f);

  @override
  Future<HttpResponse> call(HttpRequest request) => _f(request);

  final HttpHandlerFunc _f;
}
