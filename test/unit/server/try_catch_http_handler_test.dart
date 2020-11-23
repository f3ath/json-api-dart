import 'package:json_api/http.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/chain_error_converter.dart';
import 'package:test/test.dart';

void main() {
  test('HTTP 500 is returned', () async {
    await TryCatchHttpHandler(Oops(), ChainErrorConverter([]))
        .call(HttpRequest('get', Uri.parse('/')))
        .then((r) {
      expect(r.statusCode, 500);
    });
  });
}

class Oops implements HttpHandler {
  @override
  Future<HttpResponse> call(HttpRequest request) {
    throw 'Oops';
  }
}
