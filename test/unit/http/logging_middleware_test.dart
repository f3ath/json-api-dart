import 'dart:convert';

import 'package:http_interop/http_interop.dart';
import 'package:json_api/http.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

main() {
  Response response = Response(200, Body.text('hello', utf8), Headers());

  Future<Response> handler(Request rq) async => response;

  group('Logging Middleware', () {
    test('Can log', () async {
      Request? loggedRq;
      Response? loggedRs;

      final request = Request('get', Uri(host: 'localhost'), Body(), Headers());
      final response = await loggingMiddleware(handler,
          onRequest: (r) => loggedRq = r,
          onResponse: (r) => loggedRs = r)(request);
      expect(loggedRq, same(request));
      expect(loggedRs, same(response));
    });
  });
}
