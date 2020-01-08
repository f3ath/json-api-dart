import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/url_design.dart';
import 'package:shelf/shelf_io.dart';
import 'package:test/test.dart';

import '../../example/server.dart';

void main() async {
  http.Request request;
  http.Response response;
  HttpServer server;
  http.Client httpClient;
  JsonApiClient client;
  final host = 'localhost';
  final port = 8081;
  final urlDesign =
      PathBasedUrlDesign(Uri(scheme: 'http', host: host, port: port));

  setUp(() async {
    httpClient = http.Client();
    client = JsonApiClient(httpClient, onHttpCall: (rq, rs) {
      request = rq;
      response = rs;
    });
    final handler = createHttpHandler(
        ShelfRequestResponseConverter(), CRUDController(), urlDesign);

    server = await serve(handler, host, port);
  });

  tearDown(() async {
    httpClient.close();
    await server.close();
  });

  group('hooks', () {
    test('onHttpCall gets called', () async {
      await client.createResource(
          urlDesign.collection('apples'), Resource('apples', '1'));

      expect(request, isNotNull);
      expect(response, isNotNull);
      expect(response.statusCode, 204);
    });
  }, testOn: 'vm');
}
