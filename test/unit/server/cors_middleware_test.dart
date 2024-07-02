import 'dart:convert';

import 'package:http_interop/http_interop.dart';
import 'package:json_api/http.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

main() {
  Request request;
  Response response = Response(200, Body.text('hello', utf8), Headers());

  Future<Response> handler(Request rq) async {
    request = rq;
    return response;
  }

  group('CORS Middleware', () {
    test('Sets the headers', () async {
      final rq = Request(
          'get',
          Uri(host: 'localhost'),
          Body(),
          Headers.from({
            'origin': ['foo']
          }));
      final rs = await corsMiddleware(handler)(rq);
      expect(rs.statusCode, equals(200));
      expect(rs.headers['Access-Control-Allow-Origin'], equals(['foo']));
      expect(rs.headers['Access-Control-Expose-Headers'], equals(['Location']));
    });

    test('Responds to OPTIONS', () async {
      final rq = Request(
          'options',
          Uri(host: 'localhost'),
          Body(),
          Headers.from({
            'origin': ['foo']
          }));
      final rs = await corsMiddleware(handler)(rq);
      expect(rs.statusCode, equals(204));
      expect(rs.headers['Access-Control-Allow-Origin'], equals(['foo']));
      expect(rs.headers['Access-Control-Expose-Headers'], equals(['Location']));
      expect(rs.headers['Access-Control-Allow-Methods'],
          equals(['POST', 'GET', 'DELETE', 'PATCH', 'OPTIONS']));
      expect(rs.headers['Access-Control-Allow-Headers'], equals(['*']));
    });

    test('Responds to OPTIONS with custom headers', () async {
      final rq = Request(
          'options',
          Uri(host: 'localhost'),
          Body(),
          Headers.from({
            'origin': ['foo'],
            'Access-Control-Request-Method': ['PUT', 'POST'],
            'Access-Control-Request-Headers': ['foo', 'bar'],
          }));
      final rs = await corsMiddleware(handler)(rq);
      expect(rs.statusCode, equals(204));
      expect(rs.headers['Access-Control-Allow-Origin'], equals(['foo']));
      expect(rs.headers['Access-Control-Expose-Headers'], equals(['Location']));
      expect(
          rs.headers['Access-Control-Allow-Methods'], equals(['PUT', 'POST']));
      expect(
          rs.headers['Access-Control-Allow-Headers'], equals(['foo', 'bar']));
    });
  });
}
