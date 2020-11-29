import 'package:http/http.dart';
import 'package:json_api/handler.dart';
import 'package:json_api/http.dart';

abstract class DartHttpHandler implements Handler<HttpRequest, HttpResponse> {
  factory DartHttpHandler([Client? client]) =>
      client != null ? _Persistent(client) : _OneOff();
}

class _Persistent implements DartHttpHandler {
  _Persistent(this.client);

  final Client client;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final response = await Response.fromStream(
        await client.send(Request(request.method, request.uri)
          ..headers.addAll(request.headers)
          ..body = request.body));
    return HttpResponse(response.statusCode, body: response.body)
      ..headers.addAll(response.headers);
  }
}

class _OneOff implements DartHttpHandler {
  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final client = Client();
    try {
      return await _Persistent(client).call(request);
    } finally {
      client.close();
    }
  }
}
