import 'package:json_api/http.dart';

class CorsHandler implements HttpHandler {
  CorsHandler(this.wrapped, {this.origin = '*'});

  final String origin;

  final HttpHandler wrapped;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    if (request.method == 'options') {
      return HttpResponse(204, headers: {
        'Access-Control-Allow-Origin': origin,
        'Access-Control-Allow-Methods':
            request.headers['Access-Control-Request-Method'] ??
                'POST, GET, OPTIONS, DELETE, PATCH',
        'Access-Control-Allow-Headers':
            request.headers['Access-Control-Request-Headers'] ?? '*'
      });
    }
    final response = await wrapped(request);
    response.headers['Access-Control-Allow-Origin'] = origin;
    return response;
  }
}
