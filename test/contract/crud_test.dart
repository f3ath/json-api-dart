import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../../example/server/demo_handler.dart';

void main() {
  late RoutingClient client;

  setUp(() async {
    client = RoutingClient(StandardUriDesign.pathOnly,
        client: Client(handler: DemoHandler()));
  });

  group('CRUD', () {
    late Resource alice;
    late Resource bob;
    late Resource post;
    late Resource comment;
    late Resource secretComment;

    setUp(() async {
      alice = (await client.createNew('users', attributes: {'name': 'Alice'}))
          .resource;
      bob = (await client.createNew('users', attributes: {'name': 'Bob'}))
          .resource;
      post = (await client.createNew('posts',
              attributes: {'title': 'Hello world'},
              one: {'author': alice.toIdentifier()},
              many: {'comments': []}))
          .resource;
      comment = (await client.createNew('comments',
              attributes: {'text': 'Hi Alice'},
              one: {'author': bob.toIdentifier()}))
          .resource;
      secretComment = (await client.createNew('comments',
              attributes: {'text': 'Secret comment'},
              one: {'author': bob.toIdentifier()}))
          .resource;
      await client
          .addMany(post.type, post.id, 'comments', [comment.toIdentifier()]);
    });

    test('Fetch a complex resource', () async {
      final response = await client.fetchCollection('posts', query: [
        Include(['author', 'comments', 'comments.author'])
      ]);

      expect(response.http.statusCode, 200);
      expect(response.collection.length, 1);
      expect(response.included.length, 3);

      final fetchedPost = response.collection.first;
      expect(fetchedPost.attributes['title'], 'Hello world');

      final fetchedAuthor = response.included
          .where(fetchedPost.one('author')!.identifier!.identifies)
          .single;
      expect(fetchedAuthor.attributes['name'], 'Alice');

      final fetchedComment =
          fetchedPost.many('comments')!.findIn(response.included).single;
      expect(fetchedComment.attributes['text'], 'Hi Alice');
    });

    test('Delete a resource', () async {
      await client.deleteResource(post.type, post.id);
      await client.fetchCollection('posts').then((r) {
        expect(r.collection, isEmpty);
      });
    });

    test('Update a resource', () async {
      await client.updateResource(post.type, post.id,
          attributes: {'title': 'Bob was here'});
      await client.fetchCollection('posts').then((r) {
        expect(r.collection.single.attributes['title'], 'Bob was here');
      });
    });

    test('Fetch a related resource', () async {
      await client.fetchRelatedResource(post.type, post.id, 'author').then((r) {
        expect(r.resource?.attributes['name'], 'Alice');
      });
    });

    test('Fetch a related collection', () async {
      await client
          .fetchRelatedCollection(post.type, post.id, 'comments')
          .then((r) {
        expect(r.collection.single.attributes['text'], 'Hi Alice');
      });
    });

    test('Fetch a to-one relationship', () async {
      await client.fetchToOne(post.type, post.id, 'author').then((r) {
        expect(r.relationship.identifier!.identifies(alice), isTrue);
      });
    });

    test('Fetch a to-many relationship', () async {
      await client.fetchToMany(post.type, post.id, 'comments').then((r) {
        expect(r.relationship.single.identifies(comment), isTrue);
      });
    });

    test('Delete a to-one relationship', () async {
      await client.deleteToOne(post.type, post.id, 'author');
      await client.fetchResource(post.type, post.id, query: [
        Include(['author'])
      ]).then((r) {
        expect(r.resource.one('author'), isEmpty);
      });
    });

    test('Replace a to-one relationship', () async {
      await client.replaceToOne(
          post.type, post.id, 'author', bob.toIdentifier());
      await client.fetchResource(post.type, post.id, query: [
        Include(['author'])
      ]).then((r) {
        expect(
            r.included
                .where(r.resource.one('author')!.identifier!.identifies)
                .single
                .attributes['name'],
            'Bob');
      });
    });

    test('Delete from a to-many relationship', () async {
      await client.deleteFromMany(
          post.type, post.id, 'comments', [comment.toIdentifier()]);
      await client.fetchResource(post.type, post.id).then((r) {
        expect(r.resource.many('comments'), isEmpty);
      });
    });

    test('Replace a to-many relationship', () async {
      await client.replaceToMany(
          post.type, post.id, 'comments', [secretComment.toIdentifier()]);
      await client.fetchResource(post.type, post.id, query: [
        Include(['comments'])
      ]).then((r) {
        expect(
            r.resource
                .many('comments')!
                .findIn(r.included)
                .single
                .attributes['text'],
            'Secret comment');
        expect(
            r.resource
                .many('comments')!
                .findIn(r.included)
                .single
                .attributes['text'],
            'Secret comment');
      });
    });

    test('Incomplete relationship', () async {});

    test('404', () async {
      final actions = <Future Function()>[
        () => client.fetchCollection('unicorns'),
        () => client.fetchResource('posts', 'zzz'),
        () => client.fetchRelatedResource(post.type, post.id, 'zzz'),
        () => client.fetchToOne(post.type, post.id, 'zzz'),
        () => client.fetchToMany(post.type, post.id, 'zzz'),
      ];
      for (final action in actions) {
        try {
          await action();
          fail('Exception expected');
        } on RequestFailure catch (e) {
          expect(e.http.statusCode, 404);
        }
      }
    });
  });
}

extension _ToManyExt on ToMany {
  /// Finds the referenced elements which are found in the [collection].
  /// The resulting [Iterable] may contain fewer elements than referred by the
  /// relationship if the [collection] does not have all of them.
  Iterable<Resource> findIn(Iterable<Resource> collection) => collection.where(
      (resource) => any((identifier) => identifier.identifies(resource)));
}

extension _IdentifierExt on Identifier {
  /// True if this identifier identifies the [resource].
  bool identifies(Resource resource) =>
      type == resource.type && id == resource.id;
}
