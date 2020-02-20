import 'dart:convert';
import 'dart:io' as dart;

import 'package:json_api/http.dart';

class DartServer {
  final HttpHandler _handler;

  DartServer(this._handler);

  Future<void> call(dart.HttpRequest request) async {
    final response = await _handler(await _convertRequest(request));
    response.headers.forEach(request.response.headers.add);
    request.response.statusCode = response.statusCode;
    request.response.write(response.body);
    await request.response.close();
  }

  Future<HttpRequest> _convertRequest(dart.HttpRequest r) async {
    final body = await r.cast<List<int>>().transform(utf8.decoder).join();
    final headers = <String, String>{};
    r.headers.forEach((k, v) => headers[k] = v.join(', '));
    return HttpRequest(r.method, r.requestedUri, body: body, headers: headers);
  }
}
