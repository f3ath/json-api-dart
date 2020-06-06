import 'dart:convert';

import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../../helper/test_http_handler.dart';

void main() {
  final handler = TestHttpHandler();
  final client = RoutingClient(JsonApiClient(handler), StandardRouting());
  test('Error status code with incorrect content-type, body is not decoded',
      () async {
    handler.nextResponse = HttpResponse(500, body: 'Something went wrong');

    final r = await client.fetchCollection('books');
    expect(r.isAsync, false);
    expect(r.isSuccessful, false);
    expect(r.isFailed, true);
    expect(r.data, isNull);
    expect(r.asyncData, isNull);
    expect(r.statusCode, 500);
  });

  test('Do not attempt to decode primary data if decoder is null', () async {
    handler.nextResponse = HttpResponse(200,
        body: jsonEncode({
          'meta': {'foo': 'bar'},
          'data': {'id': '123', 'type': 'books'}
        }));

    final r = await client.deleteResource('books', '123');
    expect(r.isAsync, false);
    expect(r.isSuccessful, true);
    expect(r.isFailed, false);
    expect(r.data, isNull);
    expect(r.document.meta['foo'], 'bar');
    expect(r.asyncData, isNull);
    expect(r.statusCode, 200);
  });
}
