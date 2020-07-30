import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:test/test.dart';

import '../../helper/test_http_handler.dart';

void main() async {
  test('request actually has the meta property', () async {
    final handler = TestHttpHandler();
    final client = JsonApiClient(handler);

    final uri = Uri.parse('https://github.com/f3ath/json-api-dart');
    final person =
        Resource('people', '123', attributes: {'name': 'Te Cheng Hung'});
    final meta = {'friend': 'Martin Fowler'};

    handler.nextResponse = HttpResponse(201);
    await client.createResourceAt(uri, person, meta: meta);

    final request = handler.requestLog.first;
    expect(request.body,
        '{"data":{"type":"people","id":"123","attributes":{"name":"Te Cheng Hung"}},"meta":{"friend":"Martin Fowler"}}');
  });
}
