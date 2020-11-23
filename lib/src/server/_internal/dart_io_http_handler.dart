import 'dart:convert';
import 'dart:io' as io;

import 'package:json_api/http.dart';

class DartIOHttpHandler {
  DartIOHttpHandler(this._handler);

  final HttpHandler _handler;

  Future<void> call(io.HttpRequest ioRequest) async {
    final request = await _convertRequest(ioRequest);
    final response = await _handler(request);
    await _sendResponse(response, ioRequest.response);
  }

  Future<void> _sendResponse(
      HttpResponse response, io.HttpResponse ioResponse) async {
    response.headers.forEach(ioResponse.headers.add);
    ioResponse.statusCode = response.statusCode;
    ioResponse.write(response.body);
    await ioResponse.close();
  }

  Future<HttpRequest> _convertRequest(io.HttpRequest ioRequest) async =>
      HttpRequest(ioRequest.method, ioRequest.requestedUri,
          body: await _readBody(ioRequest))
        ..headers.addAll(_convertHeaders(ioRequest.headers));

  Future<String> _readBody(io.HttpRequest ioRequest) =>
      ioRequest.cast<List<int>>().transform(utf8.decoder).join();

  Map<String, String> _convertHeaders(io.HttpHeaders ioHeaders) {
    final headers = <String, String>{};
    ioHeaders.forEach((k, v) => headers[k] = v.join(','));
    return headers;
  }
}
