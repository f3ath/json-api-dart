import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/in_memory_repository.dart';
import 'package:json_api/src/server/repository_controller.dart';
import 'package:json_api/uri_design.dart';
import 'package:test/test.dart';

import '../helper/expect_resources_equal.dart';

void main() async {
  JsonApiClient client;
  JsonApiServer server;
  final host = 'localhost';
  final port = 80;
  final base = Uri(scheme: 'http', host: host, port: port);
  final design = UriDesign.standard(base);
  final wonderland =
      Resource('countries', '1', attributes: {'name': 'Wonderland'});
  final alice = Resource('people', '1',
      attributes: {'name': 'Alice'},
      toOne: {'birthplace': Identifier.of(wonderland)});
  final bob = Resource('people', '2',
      attributes: {'name': 'Bob'},
      toOne: {'birthplace': Identifier.of(wonderland)});
  final comment1 = Resource('comments', '1',
      attributes: {'text': 'First comment!'},
      toOne: {'author': Identifier.of(bob)});
  final comment2 = Resource('comments', '2',
      attributes: {'text': 'Oh hi Bob'},
      toOne: {'author': Identifier.of(alice)});
  final post = Resource('posts', '1', attributes: {
    'title': 'Hello World'
  }, toOne: {
    'author': Identifier.of(alice)
  }, toMany: {
    'comments': [Identifier.of(comment1), Identifier.of(comment2)],
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
    server = JsonApiServer(design, RepositoryController(repository));
    client = JsonApiClient(server, uriFactory: design);
  });

  group('Single Resouces', () {
    test('included == null by default', () async {
      final r = await client.fetchResource('posts', '1');
      expectResourcesEqual(r.data.unwrap(), post);
      expect(r.data.included, isNull);
    });

    test('included == [] when requested but nothing to include', () async {
      final r = await client.fetchResource('posts', '1',
          parameters: Include(['tags']));
      expectResourcesEqual(r.data.unwrap(), post);
      expect(r.data.included, []);
    });

    test('can include first-level relatives', () async {
      final r = await client.fetchResource('posts', '1',
          parameters: Include(['comments']));
      expectResourcesEqual(r.data.unwrap(), post);
      expect(r.data.included.length, 2);
      expectResourcesEqual(r.data.included[0].unwrap(), comment1);
      expectResourcesEqual(r.data.included[1].unwrap(), comment2);
    });

    test('can include second-level relatives', () async {
      final r = await client.fetchResource('posts', '1',
          parameters: Include(['comments.author']));
      expectResourcesEqual(r.data.unwrap(), post);
      expect(r.data.included.length, 2);
      expectResourcesEqual(r.data.included.first.unwrap(), bob);
      expectResourcesEqual(r.data.included.last.unwrap(), alice);
    });

    test('can include third-level relatives', () async {
      final r = await client.fetchResource('posts', '1',
          parameters: Include(['comments.author.birthplace']));
      expectResourcesEqual(r.data.unwrap(), post);
      expect(r.data.included.length, 1);
      expectResourcesEqual(r.data.included.first.unwrap(), wonderland);
    });

    test('can include first- and second-level relatives', () async {
      final r = await client.fetchResource('posts', '1',
          parameters: Include(['comments', 'comments.author']));
      expectResourcesEqual(r.data.unwrap(), post);
      expect(r.data.included.length, 4);
      expectResourcesEqual(r.data.included[0].unwrap(), comment1);
      expectResourcesEqual(r.data.included[1].unwrap(), comment2);
      expectResourcesEqual(r.data.included[2].unwrap(), bob);
      expectResourcesEqual(r.data.included[3].unwrap(), alice);
    });
  });

  group('Resource Collection', () {
    test('included == null by default', () async {
      final r = await client.fetchCollection('posts');
      expectResourcesEqual(r.data.unwrap().first, post);
      expect(r.data.included, isNull);
    });

    test('included == [] when requested but nothing to include', () async {
      final r =
          await client.fetchCollection('posts', parameters: Include(['tags']));
      expectResourcesEqual(r.data.unwrap().first, post);
      expect(r.data.included, []);
    });

    test('can include first-level relatives', () async {
      final r = await client.fetchCollection('posts',
          parameters: Include(['comments']));
      expectResourcesEqual(r.data.unwrap().first, post);
      expect(r.data.included.length, 2);
      expectResourcesEqual(r.data.included[0].unwrap(), comment1);
      expectResourcesEqual(r.data.included[1].unwrap(), comment2);
    });

    test('can include second-level relatives', () async {
      final r = await client.fetchCollection('posts',
          parameters: Include(['comments.author']));
      expectResourcesEqual(r.data.unwrap().first, post);
      expect(r.data.included.length, 2);
      expectResourcesEqual(r.data.included.first.unwrap(), bob);
      expectResourcesEqual(r.data.included.last.unwrap(), alice);
    });

    test('can include third-level relatives', () async {
      final r = await client.fetchCollection('posts',
          parameters: Include(['comments.author.birthplace']));
      expectResourcesEqual(r.data.unwrap().first, post);
      expect(r.data.included.length, 1);
      expectResourcesEqual(r.data.included.first.unwrap(), wonderland);
    });

    test('can include first- and second-level relatives', () async {
      final r = await client.fetchCollection('posts',
          parameters: Include(['comments', 'comments.author']));
      expectResourcesEqual(r.data.unwrap().first, post);
      expect(r.data.included.length, 4);
      expectResourcesEqual(r.data.included[0].unwrap(), comment1);
      expectResourcesEqual(r.data.included[1].unwrap(), comment2);
      expectResourcesEqual(r.data.included[2].unwrap(), bob);
      expectResourcesEqual(r.data.included[3].unwrap(), alice);
    });
  });
}
