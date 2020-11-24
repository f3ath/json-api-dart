import 'package:json_api/handler.dart';
import 'package:json_api/http.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/chain_error_converter.dart';
import 'package:test/test.dart';

void main() {
  test('HTTP 500 is returned', () async {
    await TryCatchHandler(
            Oops(),
            ChainErrorConverter<dynamic, JsonApiResponse>(
                [], () async => JsonApiResponse.internalServerError()))
        .call(HttpRequest('get', Uri.parse('/')))
        .then((r) {
      expect(r.statusCode, 500);
    });
  });
}

class Oops implements Handler<HttpRequest, JsonApiResponse> {
  @override
  Future<JsonApiResponse> call(HttpRequest request) {
    throw 'Oops';
  }
}
