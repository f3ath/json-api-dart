import 'package:json_api/handler.dart';
import 'package:json_api/http.dart';

/// An [HttpHandler] wrapper. Adds CORS headers and handles pre-flight requests.
class CorsHttpHandler implements Handler<HttpRequest, HttpResponse> {
  CorsHttpHandler(this._wrapped);

  final Handler<HttpRequest, HttpResponse> _wrapped;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    if (request.isOptions) {
      return HttpResponse(204)
        ..headers.addAll({
          'Access-Control-Allow-Origin': request.headers['origin'] ?? '*',
          'Access-Control-Allow-Methods':
              // TODO: Chrome works only with uppercase, but Firefox - only without. WTF?
              request.headers['Access-Control-Request-Method'].toUpperCase(),
          'Access-Control-Allow-Headers':
              request.headers['Access-Control-Request-Headers'] ?? '*',
        });
    }
    return await _wrapped(request)
      ..headers['Access-Control-Allow-Origin'] =
          request.headers['origin'] ?? '*';
  }
}
