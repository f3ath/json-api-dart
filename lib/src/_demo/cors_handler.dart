import 'package:json_api/http.dart';

class CorsHandler implements HttpHandler {
  CorsHandler(this.wrapped, {this.origin = '*'});

  final String origin;

  final HttpHandler wrapped;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    if (request.method == 'options') {
      return HttpResponse(204, headers: {
        'Access-Control-Allow-Origin': request.headers['origin'] ?? origin,
        'Access-Control-Allow-Methods':
            // TODO: Chrome works only with uppercase, but Firefox - only without. WTF?
            request.headers['Access-Control-Request-Method'].toUpperCase(),
        'Access-Control-Allow-Headers':
            request.headers['Access-Control-Request-Headers'] ?? '*',
      });
    }
    final response = await wrapped(request);
    response.headers['Access-Control-Allow-Origin'] =
        request.headers['origin'] ?? origin;
    return response;
  }
}
