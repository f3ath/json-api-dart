import 'dart:async';

import 'package:json_api/server.dart';
import 'package:shelf/shelf.dart';

class ShelfRequestResponseConverter
    implements HttpMessageConverter<Request, Response> {
  @override
  FutureOr<Response> createResponse(
          int statusCode, String body, Map<String, String> headers) =>
      Response(statusCode, body: body, headers: headers);

  @override
  FutureOr<String> getBody(Request request) => request.readAsString();

  @override
  FutureOr<String> getMethod(Request request) => request.method;

  @override
  FutureOr<Uri> getUri(Request request) => request.requestedUri;
}
