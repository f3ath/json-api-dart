import 'package:json_api/http.dart';
import 'package:json_api/src/http/last_value_logger.dart';
import 'package:test/test.dart';

void main() {
  test('Logging handler can log', () async {
    final rq = HttpRequest('get', Uri.parse('http://localhost'));
    final rs = HttpResponse(200, body: 'Hello');
    final log = LastValueLogger();
    final handler =
        LoggingHttpHandler(HttpHandler.fromFunction((_) async => rs), log);
    await handler(rq);
    expect(log.request, same(rq));
    expect(log.response, same(rs));
  });
}
