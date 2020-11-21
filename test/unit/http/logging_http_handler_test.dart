import 'package:json_api/http.dart';
import 'package:json_api/src/http/callback_http_logger.dart';
import 'package:test/test.dart';

void main() {
  test('Logging handler can log', () async {
    final rq = HttpRequest('get', Uri.parse('http://localhost'));
    final rs = HttpResponse(200, body: 'Hello');
    final log = CallbackHttpLogger(onRequest: (r) {
      expect(r, same(rq));
    }, onResponse: (r) {
      expect(r, same(rs));
    });
    final handler =
        LoggingHttpHandler(HttpHandler.fromFunction((_) async => rs), log);
    await handler(rq);
  });
}
