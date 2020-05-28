import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:test/test.dart';

import '../../helper/test_http_handler.dart';

void main() {
  group("Decode body with", () {
    final stringBodyRu = 'йцукен';
    final bytesBodyRu = utf8.encode(stringBodyRu);
    final stringBodyEn = 'qwerty';
    final bytesBodyEn = utf8.encode(stringBodyEn);

    final dartHttpWithBytesBodyAndEncoding = (
      List<int> bytesBody,
      Encoding encoding,
    ) {
      return DartHttp(
        MockClient(
          (request) async {
            return http.Response.bytes(bytesBody, 200);
          },
        ),
        encoding,
      );
    };

    test('UTF-8 ru', () async {
      final dartHttp = dartHttpWithBytesBodyAndEncoding(bytesBodyRu, utf8);

      final response =
          await dartHttp.call(HttpRequest('', Uri.parse('http://test.com')));

      expect(response.body, equals(stringBodyRu));
    });

    test('latin1 ru', () async {
      final dartHttp = dartHttpWithBytesBodyAndEncoding(bytesBodyRu, latin1);

      final response =
          await dartHttp.call(HttpRequest('', Uri.parse('http://test.com')));

      expect(response.body, isNot(equals(stringBodyRu)));
    });

    test('UTF-8 en', () async {
      final dartHttp = dartHttpWithBytesBodyAndEncoding(bytesBodyEn, utf8);

      final response =
          await dartHttp.call(HttpRequest('', Uri.parse('http://test.com')));

      expect(response.body, equals(stringBodyEn));
    });

    test('latin1 en', () async {
      final dartHttp = dartHttpWithBytesBodyAndEncoding(bytesBodyEn, latin1);

      final response =
          await dartHttp.call(HttpRequest('', Uri.parse('http://test.com')));

      expect(response.body, equals(stringBodyEn));
    });
  });
}
