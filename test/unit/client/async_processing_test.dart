import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:test/test.dart';

import '../../helper/test_http_handler.dart';

void main() {
  final handler = TestHttpHandler();
  final client = RoutingClient(JsonApiClient(handler), StandardRouting());
  final routing = StandardRouting();

  test('Client understands async responses', () async {
    final links = StandardLinks(Uri.parse('/books'), routing);
    final responseFactory =
        HttpResponseConverter(DocumentFactory(links: links), routing);
    handler.nextResponse = responseFactory.accepted(Resource('jobs', '42'));

    final r = await client.createResource(Resource('books', '1'));
    expect(r.isAsync, true);
    expect(r.isSuccessful, false);
    expect(r.isFailed, false);
    expect(r.asyncData.unwrap().type, 'jobs');
    expect(r.asyncData.unwrap().id, '42');
    expect(r.contentLocation.toString(), '/jobs/42');
  });
}
