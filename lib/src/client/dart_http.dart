import 'package:http/http.dart';
import 'package:json_api/http.dart';

/// A handler using the built-in http client
class DartHttp implements HttpHandler {
  /// Creates an instance of [DartHttp].
  /// If [client] is passed, it will be used to keep a persistent connection.
  /// In this case it is your responsibility to call [Client.close].
  /// If [client] is omitted, a new connection will be established for each call.
  const DartHttp({Client client}) : _client = client;

  final Client _client;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final response = await _call(Request(request.method, request.uri)
      ..headers.addAll(request.headers)
      ..body = request.body);
    return HttpResponse(response.statusCode, body: response.body)
      ..headers.addAll(response.headers);
  }

  Future<Response> _call(Request request) async {
    if (_client != null) return await _send(request, _client);
    final tempClient = Client();
    try {
      return await _send(request, tempClient);
    } finally {
      tempClient.close();
    }
  }

  Future<Response> _send(Request request, Client client) async =>
      await Response.fromStream(await client.send(request));
}
