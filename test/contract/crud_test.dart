import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../../demo/demo_handler.dart';

void main() {
  late RoutingClient client;

  setUp(() async {
    client =
        RoutingClient(StandardUriDesign.pathOnly, BasicClient(DemoHandler()));
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
              one: {'author': Identifier.of(alice)},
              many: {'comments': []}))
          .resource;
      comment = (await client.createNew('comments',
              attributes: {'text': 'Hi Alice'},
              one: {'author': Identifier.of(bob)}))
          .resource;
      secretComment = (await client.createNew('comments',
              attributes: {'text': 'Secret comment'},
              one: {'author': Identifier.of(bob)}))
          .resource;
      await client
          .addMany(post.type, post.id, 'comments', [Identifier.of(comment)]);
    });

    test('Fetch a complex resource', () async {
      final response = await client.fetchCollection('posts',
          include: ['author', 'comments', 'comments.author']);

      expect(response.http.statusCode, 200);
      expect(response.collection.length, 1);
      expect(response.included.length, 3);

      final fetchedPost = response.collection.first;
      expect(fetchedPost.attributes['title'], 'Hello world');

      final fetchedAuthor =
          fetchedPost.one('author')!.findIn(response.included);
      expect(fetchedAuthor?.attributes['name'], 'Alice');

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
        expect(Identity.same(r.relationship.identifier!, alice), isTrue);
      });
    });

    test('Fetch a to-many relationship', () async {
      await client.fetchToMany(post.type, post.id, 'comments').then((r) {
        expect(Identity.same(r.relationship.single, comment), isTrue);
      });
    });

    test('Delete a to-one relationship', () async {
      await client.deleteToOne(post.type, post.id, 'author');
      await client
          .fetchResource(post.type, post.id, include: ['author']).then((r) {
        expect(r.resource.one('author'), isEmpty);
      });
    });

    test('Replace a to-one relationship', () async {
      await client.replaceToOne(
          post.type, post.id, 'author', Identifier.of(bob));
      await client
          .fetchResource(post.type, post.id, include: ['author']).then((r) {
        expect(r.resource.one('author')?.findIn(r.included)?.attributes['name'],
            'Bob');
      });
    });

    test('Delete from a to-many relationship', () async {
      await client.deleteFromMany(
          post.type, post.id, 'comments', [Identifier.of(comment)]);
      await client.fetchResource(post.type, post.id).then((r) {
        expect(r.resource.many('comments'), isEmpty);
      });
    });

    test('Replace a to-many relationship', () async {
      await client.replaceToMany(
          post.type, post.id, 'comments', [Identifier.of(secretComment)]);
      await client
          .fetchResource(post.type, post.id, include: ['comments']).then((r) {
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
