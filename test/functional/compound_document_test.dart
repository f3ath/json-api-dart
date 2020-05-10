import 'package:json_api/client.dart';
import 'package:json_api/document.dart' as d;
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/in_memory_repository.dart';
import 'package:json_api/src/server/repository_controller.dart';
import 'package:test/test.dart';

void main() async {
  JsonApiClient client;
  JsonApiServer server;
  final host = 'localhost';
  final port = 80;
  final base = Uri(scheme: 'http', host: host, port: port);
  final routing = StandardRouting(base);
  final wonderland =
      d.Resource('countries', '1', attributes: {'name': 'Wonderland'});
  final alice = d.Resource('people', '1',
      attributes: {'name': 'Alice'},
      toOne: {'birthplace': d.Identifier(wonderland.type, wonderland.id)});
  final bob = d.Resource('people', '2',
      attributes: {'name': 'Bob'},
      toOne: {'birthplace': d.Identifier(wonderland.type, wonderland.id)});
  final comment1 = d.Resource('comments', '1',
      attributes: {'text': 'First comment!'},
      toOne: {'author': d.Identifier(bob.type, bob.id)});
  final comment2 = d.Resource('comments', '2',
      attributes: {'text': 'Oh hi Bob'},
      toOne: {'author': d.Identifier(alice.type, alice.id)});
  final post = d.Resource('posts', '1', attributes: {
    'title': 'Hello World'
  }, toOne: {
    'author': d.Identifier(alice.type, alice.id)
  }, toMany: {
    'comments': [
      d.Identifier(comment1.type, comment1.id),
      d.Identifier(comment2.type, comment2.id)
    ],
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
    test('included == [] when requested but nothing to include', () async {
      final r = await client.fetchResource('posts', '1', include: ['tags']);
      expect(r.resource.key, 'posts:1');
      expect(r.included, []);
      expect(r.links['self'].toString(), '/posts/1?include=tags');
    });

    test('can include first-level relatives', () async {
      final r = await client.fetchResource('posts', '1', include: ['comments']);
      expect(r.resource.key, 'posts:1');
      expect(r.included.length, 2);
      expect(r.included.first.key, 'comments:1');
      expect(r.included.last.key, 'comments:2');
    });

    test('can include second-level relatives', () async {
      final r = await client
          .fetchResource('posts', '1', include: ['comments.author']);
      expect(r.resource.key, 'posts:1');
      expect(r.included.length, 2);
      expect(r.included.first.attributes['name'], 'Bob');
      expect(r.included.last.attributes['name'], 'Alice');
    });

    test('can include third-level relatives', () async {
      final r = await client
          .fetchResource('posts', '1', include: ['comments.author.birthplace']);
      expect(r.resource.key, 'posts:1');
      expect(r.included.length, 1);
      expect(r.included.first.attributes['name'], 'Wonderland');
    });

    test('can include first- and second-level relatives', () async {
      final r = await client.fetchResource('posts', '1',
          include: ['comments', 'comments.author']);
      expect(r.resource.key, 'posts:1');
      expect(r.included.length, 4);
      expect(r.included.toList()[0].key, 'comments:1');
      expect(r.included.toList()[1].key, 'comments:2');
      expect(r.included.toList()[2].attributes['name'], 'Bob');
      expect(r.included.toList()[3].attributes['name'], 'Alice');
    });
  });

  group('Resource Collection', () {
    test('not compound by default', () async {
      final r = await client.fetchCollection('posts');
      expect(r.first.key, 'posts:1');
      expect(r.included.isEmpty, true);
    });

    test('document is compound when requested but nothing to include',
        () async {
      final r = await client.fetchCollection('posts', include: ['tags']);
      expect(r.first.key, 'posts:1');
      expect(r.included.isEmpty, true);
    });

    test('can include first-level relatives', () async {
      final r = await client.fetchCollection('posts', include: ['comments']);
      expect(r.first.type, 'posts');
      expect(r.included.length, 2);
      expect(r.included.first.key, 'comments:1');
      expect(r.included.last.key, 'comments:2');
    });

    test('can include second-level relatives', () async {
      final r =
          await client.fetchCollection('posts', include: ['comments.author']);
      expect(r.first.type, 'posts');
      expect(r.included.length, 2);
      expect(r.included.first.attributes['name'], 'Bob');
      expect(r.included.last.attributes['name'], 'Alice');
    });

    test('can include third-level relatives', () async {
      final r = await client
          .fetchCollection('posts', include: ['comments.author.birthplace']);
      expect(r.first.key, 'posts:1');
      expect(r.included.length, 1);
      expect(r.included.first.attributes['name'], 'Wonderland');
    });

    test('can include first- and second-level relatives', () async {
      final r = await client
          .fetchCollection('posts', include: ['comments', 'comments.author']);
      expect(r.first.key, 'posts:1');
      expect(r.included.length, 4);
      expect(r.included.toList()[0].key, 'comments:1');
      expect(r.included.toList()[1].key, 'comments:2');
      expect(r.included.toList()[2].attributes['name'], 'Bob');
      expect(r.included.toList()[3].attributes['name'], 'Alice');
    });
  });
}
