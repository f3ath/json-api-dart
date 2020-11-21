import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/http/callback_http_logger.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  StreamChannel channel;
  JsonApiClient client;

  Future<void> after<R>(JsonApiRequest<R> request,
      [void Function(R response) check]) async {
    final response = await client(request);
    check?.call(response);
  }

  setUp(() async {
    channel = spawnHybridUri('hybrid_server.dart');
    final serverUrl = await channel.stream.first;
    // final serverUrl = 'http://localhost:8080';

    client = JsonApiClient(LoggingHttpHandler(DartHttp(), CallbackHttpLogger()),
        RecommendedUrlDesign(Uri.parse(serverUrl.toString())));
  });

  /// Goal: test different HTTP methods in a browser
  test('Basic Client-Server interaction over HTTP', () async {
    final id = Uuid().v4();
    await client(
        Request.create('posts', id, attributes: {'title': 'Hello world'}));
    await after(Request.fetchResource('posts', id), (r) {
      expect(r.resource.attributes['title'], 'Hello world');
    });
    await client(Request.updateResource('posts', id,
        attributes: {'title': 'Bye world'}));
    await after(Request.fetchResource('posts', id), (r) {
      expect(r.resource.attributes['title'], 'Bye world');
    });
    await client(Request.deleteResource('posts', id));
    await after(Request.fetchCollection('posts'), (r) {
      expect(r.collection, isEmpty);
    });
  });
}
