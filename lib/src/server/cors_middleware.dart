import 'package:http_interop/http_interop.dart';
import 'package:http_interop_middleware/http_interop_middleware.dart';

final corsMiddleware = middleware(
    onRequest: (rq) async => switch (rq.method) {
          'options' => Response(
              204,
              Body(),
              Headers.from({
                'Access-Control-Allow-Methods':
                    rq.headers['Access-Control-Request-Method'] ??
                        const ['POST', 'GET', 'DELETE', 'PATCH', 'OPTIONS'],
                'Access-Control-Allow-Headers':
                    rq.headers['Access-Control-Request-Headers'] ?? const ['*'],
              })),
          _ => null
        },
    onResponse: (rs, rq) async => rs
      ..headers.addAll({
        'Access-Control-Allow-Origin': [rq.headers['origin']?.last ?? '*'],
        'Access-Control-Expose-Headers': const ['Location'],
      }));
