import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../../helper/test_http_handler.dart';

void main() {
  final handler = TestHttpHandler();
  final client = RoutingClient(JsonApiClient(handler), StandardRouting());
  test('Error status code with incorrect content-type is not decoded',
      () async {
    handler.nextResponse = HttpResponse(500, body: 'Something went wrong');

    final r = await client.fetchCollection('books');
    expect(r.isAsync, false);
    expect(r.isSuccessful, false);
    expect(r.isFailed, true);
    expect(r.data, isNull);
    expect(r.asyncData, isNull);
    expect(r.statusCode, 500);
  });
}
