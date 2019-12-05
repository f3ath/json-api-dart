import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:json_api/json_api.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';

import '../../example/cars_server.dart';

void main() async {
  HttpServer server;
  http.Client httpClient;
  JsonApiClient client;
  http.Request request;
  http.Response response;
  final port = 8083;
  final urlDesign = PathBasedUrlDesign(Uri.parse('http://localhost:$port'));

  setUp(() async {
    httpClient = http.Client();
    client = JsonApiClient(httpClient, onHttpCall: (req, resp) {
      request = req;
      response = resp;
    });
    server = await createServer(InternetAddress.loopbackIPv4, port);
  });

  tearDown(() async {
    httpClient.close();
    await server.close();
  });

  group('hooks', () {
    test('onHttpCall gets called', () async {
      await client.fetchCollection(urlDesign.collection('companies'));

      expect(request, isNotNull);
      expect(response, isNotNull);
      expect(response.body, isNotEmpty);
    });
  });
}
