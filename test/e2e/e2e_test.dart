import 'package:http/http.dart' as http;
import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../example/demo/printing_logger.dart';

void main() {
  final sql = '''
    CREATE TABLE books (
      id TEXT NOT NULL PRIMARY KEY,
      title TEXT
    );
  ''';

  final logger = PrintingLogger();

  StreamChannel channel;
  http.Client httpClient;
  JsonApiClient client;

  setUp(() async {
    channel = spawnHybridUri('hybrid_server.dart', message: sql);
    final serverUrl = await channel.stream.first;
    // final serverUrl = 'http://localhost:8080';
    httpClient = http.Client();

    client = JsonApiClient(LoggingHttpHandler(DartHttp(httpClient), logger),
        RecommendedUrlDesign(Uri.parse(serverUrl.toString())));
  });

  tearDown(() async {
    httpClient.close();
  });

  group('Basic Client-Server interaction over HTTP', () {
    test('Create new resource, read collection', () async {
      final r0 = await client(
          Request.createNew('books', attributes: {'title': 'Hello world'}));
      expect(r0.http.statusCode, 201);
      expect(r0.links['self'].toString(), '/books/${r0.resource.id}');
      expect(r0.resource.type, 'books');
      expect(r0.resource.id, isNotEmpty);
      expect(r0.resource.attributes['title'], 'Hello world');
      expect(r0.resource.links['self'].toString(), '/books/${r0.resource.id}');

      final r1 = await client(Request.fetchCollection('books'));
      expect(r1.http.statusCode, 200);
      expect(r1.collection.first.type, 'books');
      expect(r1.collection.first.attributes['title'], 'Hello world');
    });

    test('Create new resource sets Location header', () async {
      // TODO: Why does this not work in browsers?
      final r0 = await client(
          Request.createNew('books', attributes: {'title': 'Hello world'}));
      expect(r0.http.statusCode, 201);
      expect(r0.http.headers['location'], '/books/${r0.resource.id}');
    }, testOn: 'vm');

    test('Create resource with id, read resource by id', () async {
      final id = Uuid().v4();
      final r0 = await client(
          Request.create('books', id, attributes: {'title': 'Hello world'}));
      expect(r0.http.statusCode, 204);
      expect(r0.resource, isNull);
      expect(r0.http.headers['location'], isNull);

      final r1 = await client(Request.fetchResource('books', id));
      expect(r1.http.statusCode, 200);
      expect(r1.http.headers['content-type'], 'application/vnd.api+json');
      expect(r1.resource.type, 'books');
      expect(r1.resource.id, id);
      expect(r1.resource.attributes['title'], 'Hello world');
    });
  });
}
