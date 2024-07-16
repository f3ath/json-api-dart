import 'dart:io';

import 'package:http_interop_middleware/http_interop_middleware.dart';

/// Middleware that logs all requests and responses to stderr.
final Middleware loggerMiddleware = middleware(
  onRequest: (r) async {
    stderr.writeln(r);
    return null;
  },
  onResponse: (r, _) async {
    stderr.writeln(r);
    return null;
  },
  onError: (e, t, _) async {
    stderr.writeln(e);
    stderr.writeln(t);
    return null;
  },
);
