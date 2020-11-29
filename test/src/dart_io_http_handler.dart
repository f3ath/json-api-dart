import 'dart:convert';
import 'dart:io' as io;

import 'package:json_api/handler.dart';
import 'package:json_api/http.dart';

Future<void> Function(io.HttpRequest ioRequest) dartIOHttpHandler(
  Handler<HttpRequest, HttpResponse> handler,
) =>
    (request) async {
      final headers = <String, String>{};
      request.headers.forEach((k, v) => headers[k] = v.join(','));
      final response = await handler(HttpRequest(
          request.method, request.requestedUri,
          body: await request.cast<List<int>>().transform(utf8.decoder).join())
        ..headers.addAll(headers));
      response.headers.forEach(request.response.headers.add);
      request.response.statusCode = response.statusCode;
      request.response.write(response.body);
      await request.response.close();
    };
