import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../example/demo/printing_logger.dart';
import '../../example/demo/sqlite_controller.dart';

void main() {
  final sql = '''
    CREATE TABLE books (
      id TEXT NOT NULL PRIMARY KEY,
      title TEXT
    );
  ''';

  JsonApiClient client;

  setUp(() async {
    final db = sqlite3.openInMemory();
    db.execute(sql);
    final controller = SqliteController(db);
    final jsonApiServer =
        JsonApiHandler(controller, exposeInternalErrors: true);

    client = JsonApiClient(
        LoggingHttpHandler(jsonApiServer, const PrintingLogger()),
        RecommendedUrlDesign.pathOnly);
  });

  group('Basic Client-Server interaction over HTTP', () {
    test('Create new resource, read collection', () async {
      final r0 = await client(CreateNewResource.build('books',
          attributes: {'title': 'Hello world'}));
      expect(r0.http.statusCode, 201);
      expect(r0.links['self'].toString(), '/books/${r0.resource.id}');
      expect(r0.resource.type, 'books');
      expect(r0.resource.id, isNotEmpty);
      expect(r0.resource.attributes['title'], 'Hello world');
      expect(r0.resource.links['self'].toString(), '/books/${r0.resource.id}');

      final r1 = await client(FetchCollection('books'));
      expect(r1.http.statusCode, 200);
      expect(r1.collection.first.type, 'books');
      expect(r1.collection.first.attributes['title'], 'Hello world');
    });

    test('Create new resource sets Location header', () async {
      // TODO: Why does this not work in browsers?
      final r0 = await client(CreateNewResource.build('books',
          attributes: {'title': 'Hello world'}));
      expect(r0.http.statusCode, 201);
      expect(r0.http.headers['location'], '/books/${r0.resource.id}');
    }, testOn: 'vm');

    test('Create resource with id, read resource by id', () async {
      final id = Uuid().v4();
      final r0 = await client(CreateResource.build('books', id,
          attributes: {'title': 'Hello world'}));
      expect(r0.http.statusCode, 204);
      expect(r0.resource, isNull);
      expect(r0.http.headers['location'], isNull);

      final r1 = await client(FetchResource.build('books', id));
      expect(r1.http.statusCode, 200);
      expect(r1.http.headers['content-type'], 'application/vnd.api+json');
      expect(r1.resource.type, 'books');
      expect(r1.resource.id, id);
      expect(r1.resource.attributes['title'], 'Hello world');
    });
  });
}
