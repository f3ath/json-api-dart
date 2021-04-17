import 'package:json_api/src/http/http_handler.dart';
import 'package:json_api/src/http/http_request.dart';
import 'package:json_api/src/http/http_response.dart';

class CorsHandler implements HttpHandler {
  CorsHandler(this._handler);

  final HttpHandler _handler;

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
              // TODO: Make it work for all browsers. Why is toUpperCase() needed?
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
