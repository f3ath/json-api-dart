import 'package:http_interop/http_interop.dart';
import 'package:json_api/http.dart';

/// CORD middleware
Handler cors(Handler handler) => (Request request) async {
      final headers = {
        'Access-Control-Allow-Origin': [request.headers.last('origin') ?? '*'],
        'Access-Control-Expose-Headers': ['Location'],
      };

      if (request.method == 'options') {
        const methods = ['POST', 'GET', 'DELETE', 'PATCH', 'OPTIONS'];
        return Response(
            204,
            Body(),
            Headers.from({
              ...headers,
              'Access-Control-Allow-Methods':
                  request.headers['Access-Control-Request-Method'] ?? methods,
              'Access-Control-Allow-Headers':
                  request.headers['Access-Control-Request-Headers'] ?? ['*'],
            }));
      }
      return await handler(request..headers.addAll(headers));
    };
