import 'package:json_api/handler.dart';
import 'package:test/test.dart';

void main() {
  test('Logging handler can log', () async {
    String loggedRequest;
    String loggedResponse;

    final handler =
        LoggingHandler(FunHandler((String s) async => s.toUpperCase()), (rq) {
      loggedRequest = rq;
    }, (rs) {
      loggedResponse = rs;
    });
    expect(await handler('foo'), 'FOO');
    expect(loggedRequest, 'foo');
    expect(loggedResponse, 'FOO');
  });
}
