import 'package:json_api/http.dart';
import 'package:test/test.dart';

void main() {
  test('Logging handler can log', () async {
    final rq = HttpRequest('get', Uri.parse('http://localhost'));
    final rs = HttpResponse(200, body: 'Hello');
    HttpRequest loggedRq;
    HttpResponse loggedRs;
    final logger = LoggingHttpHandler(
        HttpHandler.fromFunction(((_) async => rs)),
        onResponse: (_) => loggedRs = _,
        onRequest: (_) => loggedRq = _);
    await logger(rq);
    expect(loggedRq, same(rq));
    expect(loggedRs, same(rs));
  });
}
