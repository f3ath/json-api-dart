import 'package:http_interop/http_interop.dart' as interop;

class CorsHandler implements interop.Handler {
  CorsHandler(this._inner);

  final interop.Handler _inner;

  @override
  Future<interop.Response> handle(interop.Request request) async {
    final headers = {
      'Access-Control-Allow-Origin': request.headers['origin'] ?? '*',
      'Access-Control-Expose-Headers': 'Location',
    };

    if (request.isOptions) {
      const methods = ['POST', 'GET', 'DELETE', 'PATCH', 'OPTIONS'];
      return interop.Response(204)
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
    return await _inner.handle(request)
      ..headers.addAll(headers);
  }
}
