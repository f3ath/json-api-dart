import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/response_factory.dart';
import 'package:test/test.dart';

import '../../helper/test_http_handler.dart';

void main() {
  final handler = TestHttpHandler();
  final routing = StandardRouting();
  final client = JsonApiClient(handler, routing);
  final responseFactory = HttpResponseFactory(routing);

  test('Client understands async responses', () async {
    handler.response = responseFactory.accepted(Resource('jobs', '42'));

    final r = await client.createResource(Resource('books', '1'));
    expect(r.isAsync, true);
    expect(r.isSuccessful, false);
    expect(r.isFailed, false);
    expect(r.decodeAsyncDocument().data.unwrap().type, 'jobs');
    expect(r.decodeAsyncDocument().data.unwrap().id, '42');
    expect(r.http.headers['content-location'], '/jobs/42');
  });
}
