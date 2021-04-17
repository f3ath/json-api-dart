import 'package:http/http.dart';
import 'package:json_api/http.dart';

/// Handler which relies on the built-in Dart HTTP client.
/// It is the developer's responsibility to instantiate the client and
/// call `close()` on it in the end pf the application lifecycle.
class PersistentHandler {
  /// Creates a new instance of the handler. Do not forget to call `close()` on
  /// the [client] when it's not longer needed.
  PersistentHandler(this.client);

  final Client client;

  Future<HttpResponse> call(HttpRequest request) async {
    final response = await Response.fromStream(
        await client.send(Request(request.method, request.uri)
          ..headers.addAll(request.headers)
          ..body = request.body));
    return HttpResponse(response.statusCode, body: response.body)
      ..headers.addAll(response.headers);
  }
}
