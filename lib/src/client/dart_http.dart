import 'package:http/http.dart';
import 'package:json_api/http.dart';

/// A handler using the built-in http client
class DartHttp implements HttpHandler {
  DartHttp(this._client);

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final response = await _send(Request(request.method, request.uri)
      ..headers.addAll(request.headers)
      ..body = request.body);
    return HttpResponse(response.statusCode,
        body: response.body, headers: response.headers);
  }

  final Client _client;

  Future<Response> _send(Request request) async =>
      Response.fromStream(await _client.send(request));
}
