import 'package:json_api/handler.dart';
import 'package:json_api/http.dart';

/// An [HttpHandler] wrapper. Adds CORS headers and handles pre-flight requests.
class CorsHttpHandler implements Handler<HttpRequest, HttpResponse> {
  CorsHttpHandler(this._handler);

  final Handler<HttpRequest, HttpResponse> _handler;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final headers = {
      'Access-Control-Allow-Origin': request.headers['origin'] ?? '*',
      'Access-Control-Expose-Headers': 'Location',
    };

    if (request.isOptions) {
      const methods = ['POST', 'GET', 'DELETE', 'PATCH', 'OPTIONS'];
      return HttpResponse(204)
        ..headers.addAll({
          ...headers,
          'Access-Control-Allow-Methods':
              // TODO: Chrome works only with uppercase, but Firefox - only without. WTF?
              request.headers['Access-Control-Request-Method']?.toUpperCase() ??
                  methods.join(', '),
          'Access-Control-Allow-Headers':
              request.headers['Access-Control-Request-Headers'] ?? '*',
        });
    }
    return await _handler(request)
      ..headers.addAll(headers);
  }
}
