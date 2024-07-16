// CORS middleware
import 'package:http_interop/http_interop.dart';

Handler corsMiddleware(Handler handler) =>
    (Request request) async => switch (request.method) {
          'options' => Response(
              204,
              Body(),
              Headers.from({
                'Access-Control-Allow-Methods':
                    request.headers['Access-Control-Request-Method'] ??
                        const ['POST', 'GET', 'DELETE', 'PATCH', 'OPTIONS'],
                'Access-Control-Allow-Headers':
                    request.headers['Access-Control-Request-Headers'] ??
                        const ['*'],
              })),
          _ => await handler(request)
        }
          ..headers.addAll({
            'Access-Control-Allow-Origin': [
              request.headers['origin']?.last ?? '*'
            ],
            'Access-Control-Expose-Headers': const ['Location'],
          });
