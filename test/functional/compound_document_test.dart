import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/in_memory_repository.dart';
import 'package:json_api/src/server/repository_controller.dart';
import 'package:test/test.dart';

import '../helper/expect_same_json.dart';

void main() async {
  JsonApiClient client;
  JsonApiServer server;
  final host = 'localhost';
  final port = 80;
  final base = Uri(scheme: 'http', host: host, port: port);
  final routing = StandardRouting(base);
  final wonderland =
      Resource('countries', '1', attributes: {'name': 'Wonderland'});
  final alice = Resource('people', '1',
      attributes: {'name': 'Alice'},
      toOne: {'birthplace': Identifier(wonderland.type, wonderland.id)});
  final bob = Resource('people', '2',
      attributes: {'name': 'Bob'},
      toOne: {'birthplace': Identifier(wonderland.type, wonderland.id)});
  final comment1 = Resource('comments', '1',
      attributes: {'text': 'First comment!'},
      toOne: {'author': Identifier(bob.type, bob.id)});
  final comment2 = Resource('comments', '2',
      attributes: {'text': 'Oh hi Bob'},
      toOne: {'author': Identifier(alice.type, alice.id)});
  final post = Resource('posts', '1', attributes: {
    'title': 'Hello World'
  }, toOne: {
    'author': Identifier(alice.type, alice.id)
  }, toMany: {
    'comments': [Identifier(comment1.type, comment1.id), Identifier(comment2.type, comment2.id)],
    'tags': []
  });

  setUp(() async {
    final repository = InMemoryRepository({
      'posts': {'1': post},
      'comments': {'1': comment1, '2': comment2},
      'people': {'1': alice, '2': bob},
      'countries': {'1': wonderland},
      'tags': {}
    });
    server = JsonApiServer(RepositoryController(repository));
    client = JsonApiClient(server, routing);
  });

  group('Single Resources', () {
    test('not compound by default', () async {
      final r = await client.fetchResource('posts', '1');
      final document = r.decodeDocument();
      expectSameJson(document.data.unwrap(), post);
      expect(document.isCompound, isFalse);
    });

    test('included == [] when requested but nothing to include', () async {
      final r = await client.fetchResource('posts', '1',
          parameters: Include(['tags']));
      expectSameJson(r.decodeDocument().data.unwrap(), post);
      expect(r.decodeDocument().included, []);
      expect(r.decodeDocument().isCompound, isTrue);
      expect(r.decodeDocument().data.links['self'].toString(),
          '/posts/1?include=tags');
    });

    test('can include first-level relatives', () async {
      final r = await client.fetchResource('posts', '1',
          parameters: Include(['comments']));
      expectSameJson(r.decodeDocument().data.unwrap(), post);
      expect(r.decodeDocument().isCompound, isTrue);
      expect(r.decodeDocument().included.length, 2);
      expectSameJson(r.decodeDocument().included[0].unwrap(), comment1);
      expectSameJson(r.decodeDocument().included[1].unwrap(), comment2);
    });

    test('can include second-level relatives', () async {
      final r = await client.fetchResource('posts', '1',
          parameters: Include(['comments.author']));
      expectSameJson(r.decodeDocument().data.unwrap(), post);
      expect(r.decodeDocument().isCompound, isTrue);
      expect(r.decodeDocument().included.length, 2);
      expectSameJson(r.decodeDocument().included.first.unwrap(), bob);
      expectSameJson(r.decodeDocument().included.last.unwrap(), alice);
    });

    test('can include third-level relatives', () async {
      final r = await client.fetchResource('posts', '1',
          parameters: Include(['comments.author.birthplace']));
      expectSameJson(r.decodeDocument().data.unwrap(), post);
      expect(r.decodeDocument().isCompound, isTrue);
      expect(r.decodeDocument().included.length, 1);
      expectSameJson(
          r.decodeDocument().included.first.unwrap(), wonderland);
    });

    test('can include first- and second-level relatives', () async {
      final r = await client.fetchResource('posts', '1',
          parameters: Include(['comments', 'comments.author']));
      expectSameJson(r.decodeDocument().data.unwrap(), post);
      expect(r.decodeDocument().included.length, 4);
      expectSameJson(r.decodeDocument().included[0].unwrap(), comment1);
      expectSameJson(r.decodeDocument().included[1].unwrap(), comment2);
      expectSameJson(r.decodeDocument().included[2].unwrap(), bob);
      expectSameJson(r.decodeDocument().included[3].unwrap(), alice);
      expect(r.decodeDocument().isCompound, isTrue);
    });
  });

  group('Resource Collection', () {
    test('not compound by default', () async {
      final r = await client.fetchCollection('posts');
      expectSameJson(r.decodeDocument().data.unwrap().first, post);
      expect(r.decodeDocument().isCompound, isFalse);
    });

    test('document is compound when requested but nothing to include',
        () async {
      final r =
          await client.fetchCollection('posts', parameters: Include(['tags']));
      expectSameJson(r.decodeDocument().data.unwrap().first, post);
      expect(r.decodeDocument().included, []);
      expect(r.decodeDocument().isCompound, isTrue);
    });

    test('can include first-level relatives', () async {
      final r = await client.fetchCollection('posts',
          parameters: Include(['comments']));
      expectSameJson(r.decodeDocument().data.unwrap().first, post);
      expect(r.decodeDocument().isCompound, isTrue);
      expect(r.decodeDocument().included.length, 2);
      expectSameJson(r.decodeDocument().included[0].unwrap(), comment1);
      expectSameJson(r.decodeDocument().included[1].unwrap(), comment2);
    });

    test('can include second-level relatives', () async {
      final r = await client.fetchCollection('posts',
          parameters: Include(['comments.author']));
      expectSameJson(r.decodeDocument().data.unwrap().first, post);
      expect(r.decodeDocument().included.length, 2);
      expectSameJson(r.decodeDocument().included.first.unwrap(), bob);
      expectSameJson(r.decodeDocument().included.last.unwrap(), alice);
      expect(r.decodeDocument().isCompound, isTrue);
    });

    test('can include third-level relatives', () async {
      final r = await client.fetchCollection('posts',
          parameters: Include(['comments.author.birthplace']));
      expectSameJson(r.decodeDocument().data.unwrap().first, post);
      expect(r.decodeDocument().isCompound, isTrue);
      expect(r.decodeDocument().included.length, 1);
      expectSameJson(
          r.decodeDocument().included.first.unwrap(), wonderland);
    });

    test('can include first- and second-level relatives', () async {
      final r = await client.fetchCollection('posts',
          parameters: Include(['comments', 'comments.author']));
      expectSameJson(r.decodeDocument().data.unwrap().first, post);
      expect(r.decodeDocument().isCompound, isTrue);
      expect(r.decodeDocument().included.length, 4);
      expectSameJson(r.decodeDocument().included[0].unwrap(), comment1);
      expectSameJson(r.decodeDocument().included[1].unwrap(), comment2);
      expectSameJson(r.decodeDocument().included[2].unwrap(), bob);
      expectSameJson(r.decodeDocument().included[3].unwrap(), alice);
    });
  });
}
