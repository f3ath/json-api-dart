import 'package:http/http.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/persistent_handler.dart';

/// This HTTP handler creates a new instance of the [Client] for every request
/// end disposes the client after the request completes.
class DisposableHandler implements HttpHandler {
  const DisposableHandler();

  @override
  Future<HttpResponse> handle(HttpRequest request) async {
    final client = Client();
    try {
      return await PersistentHandler(client).call(request);
    } finally {
      client.close();
    }
  }
}
