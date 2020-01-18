import 'dart:async';

import 'package:json_api/server.dart';
import 'package:shelf/shelf.dart' as shelf;

class ShelfRequestResponseConverter
    implements HttpMessageConverter<shelf.Request, shelf.Response> {
  @override
  FutureOr<shelf.Response> createResponse(
          int statusCode, String body, Map<String, String> headers) =>
      shelf.Response(statusCode, body: body, headers: headers);

  @override
  FutureOr<String> getBody(shelf.Request request) => request.readAsString();

  @override
  FutureOr<String> getMethod(shelf.Request request) => request.method;

  @override
  FutureOr<Uri> getUri(shelf.Request request) => request.requestedUri;
}
