import 'package:http/http.dart';
import 'package:json_api/http.dart';

/// A handler using the Dart's built-in http client
class DartHttp implements HttpHandler {
  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final response = await _send(Request(request.method, request.uri)
      ..headers.addAll(request.headers)
      ..body = request.body);
    return HttpResponse(response.statusCode,
        body: response.body, headers: response.headers);
  }

  DartHttp(this._client);

  final Client _client;

  Future<Response> _send(Request dartRequest) async =>
      Response.fromStream(await _client.send(dartRequest));
}
