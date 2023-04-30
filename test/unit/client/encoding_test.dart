import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_http/http_interop_http.dart';
import 'package:test/test.dart';

void main() {
  group('Decode body with', () {
    final stringBodyRu = 'йцукен';
    final bytesBodyRu = utf8.encode(stringBodyRu);
    final stringBodyEn = 'qwerty';
    final bytesBodyEn = utf8.encode(stringBodyEn);

    buildResponse(
      List<int> bytesBody,
      Encoding encoding,
    ) async {
      final dartHttp = HandlerWrapper(
        MockClient(
          (request) async {
            return http.Response.bytes(bytesBody, 200);
          },
        ),
        messageConverter: MessageConverter(defaultResponseEncoding: encoding),
      );

      return dartHttp
          .handle(HttpRequest('get', Uri.parse('http://test.com')));
    }

    test('UTF-8 ru', () async {
      final response = await buildResponse(bytesBodyRu, utf8);
      expect(response.body, equals(stringBodyRu));
    });

    test('latin1 ru', () async {
      final response = await buildResponse(bytesBodyRu, latin1);
      expect(response.body, isNot(equals(stringBodyRu)));
    });

    test('UTF-8 en', () async {
      final response = await buildResponse(bytesBodyEn, utf8);
      expect(response.body, equals(stringBodyEn));
    });

    test('latin1 en', () async {
      final response = await buildResponse(bytesBodyEn, latin1);
      expect(response.body, equals(stringBodyEn));
    });
  });
}
