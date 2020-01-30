import 'dart:async';

import 'package:json_api/http.dart';
import 'package:json_api/src/server/json_api_server.dart';
import 'package:shelf/shelf.dart';

class ShelfAdapter {
  final JsonApiServer _server;

  ShelfAdapter(this._server);

  FutureOr<Response> call(Request request) async {
    final rq = HttpRequest(request.method, request.requestedUri,
        body: await request.readAsString(), headers: request.headers);
    final rs = await _server(rq);
    return Response(rs.statusCode, body: rs.body, headers: rs.headers);
  }
}
