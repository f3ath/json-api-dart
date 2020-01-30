import 'package:http/http.dart';
import 'package:json_api/http.dart';

/// A handler using the Dart's built-in http client
class DartHttpClient implements HttpHandler {
  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final response = await _send(Request(request.method, request.uri)
      ..headers.addAll(request.headers)
      ..body = request.body);
    return HttpResponse(response.statusCode,
        body: response.body, headers: response.headers);
  }

  /// Calls the inner client's `close()`. You have to either call this method
  /// or close the inner client yourself!
  ///
  /// See https://pub.dev/documentation/http/latest/http/Client/close.html
  void close() => _client.close();

  DartHttpClient([Client client]) : _client = client ?? Client();

  final Client _client;

  Future<Response> _send(Request dartRequest) async =>
      Response.fromStream(await _client.send(dartRequest));
}
