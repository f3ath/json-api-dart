import 'package:http_interop/http_interop.dart';

class CorsHandler implements Handler {
  CorsHandler(this._inner);

  final Handler _inner;

  @override
  Future<Response> handle(Request request) async {
    final headers = {
      'Access-Control-Allow-Origin': request.headers['origin'] ?? '*',
      'Access-Control-Expose-Headers': 'Location',
    };

    if (request.method.equals('OPTIONS')) {
      const methods = ['POST', 'GET', 'DELETE', 'PATCH', 'OPTIONS'];
      return Response(
          204,
          Body.empty(),
          Headers({
            ...headers,
            'Access-Control-Allow-Methods':
                // TODO: Make it work for all browsers. Why is toUpperCase() needed?
                request.headers['Access-Control-Request-Method']
                        ?.toUpperCase() ??
                    methods.join(', '),
            'Access-Control-Allow-Headers':
                request.headers['Access-Control-Request-Headers'] ?? '*',
          }));
    }
    return await _inner.handle(request..headers.addAll(headers));
  }
}
