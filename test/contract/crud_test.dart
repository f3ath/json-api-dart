import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../src/demo_handler.dart';

void main() {
  late JsonApiClient client;

  setUp(() async {
    client = JsonApiClient(DemoHandler(), RecommendedUrlDesign.pathOnly);
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
              one: {'author': Identifier(alice.ref)},
              many: {'comments': []}))
          .resource;
      comment = (await client.createNew('comments',
              attributes: {'text': 'Hi Alice'},
              one: {'author': Identifier(bob.ref)}))
          .resource;
      secretComment = (await client.createNew('comments',
              attributes: {'text': 'Secret comment'},
              one: {'author': Identifier(bob.ref)}))
          .resource;
      await client.addMany(
          post.ref.type, post.ref.id, 'comments', [Identifier(comment.ref)]);
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
      await client.deleteResource(post.ref.type, post.ref.id);
      await client.fetchCollection('posts').then((r) {
        expect(r.collection, isEmpty);
      });
    });

    test('Update a resource', () async {
      await client.updateResource(post.ref.type, post.ref.id,
          attributes: {'title': 'Bob was here'});
      await client.fetchCollection('posts').then((r) {
        expect(r.collection.single.attributes['title'], 'Bob was here');
      });
    });

    test('Fetch a related resource', () async {
      await client
          .fetchRelatedResource(post.ref.type, post.ref.id, 'author')
          .then((r) {
        expect(r.resource?.attributes['name'], 'Alice');
      });
    });

    test('Fetch a related collection', () async {
      await client
          .fetchRelatedCollection(post.ref.type, post.ref.id, 'comments')
          .then((r) {
        expect(r.collection.single.attributes['text'], 'Hi Alice');
      });
    });

    test('Fetch a to-one relationship', () async {
      await client.fetchToOne(post.ref.type, post.ref.id, 'author').then((r) {
        expect(r.relationship.identifier?.ref, alice.ref);
      });
    });

    test('Fetch a to-many relationship', () async {
      await client
          .fetchToMany(post.ref.type, post.ref.id, 'comments')
          .then((r) {
        expect(r.relationship.single.ref, comment.ref);
      });
    });

    test('Delete a to-one relationship', () async {
      await client.deleteToOne(post.ref.type, post.ref.id, 'author');
      await client.fetchResource(post.ref.type, post.ref.id,
          include: ['author']).then((r) {
        expect(r.resource.one('author'), isEmpty);
      });
    });

    test('Replace a to-one relationship', () async {
      await client.replaceToOne(
          post.ref.type, post.ref.id, 'author', Identifier(bob.ref));
      await client.fetchResource(post.ref.type, post.ref.id,
          include: ['author']).then((r) {
        expect(r.resource.one('author')?.findIn(r.included)?.attributes['name'],
            'Bob');
      });
    });

    test('Delete from a to-many relationship', () async {
      await client.deleteFromToMany(
          post.ref.type, post.ref.id, 'comments', [Identifier(comment.ref)]);
      await client.fetchResource(post.ref.type, post.ref.id).then((r) {
        expect(r.resource.many('comments'), isEmpty);
      });
    });

    test('Replace a to-many relationship', () async {
      await client.replaceToMany(post.ref.type, post.ref.id, 'comments',
          [Identifier(secretComment.ref)]);
      await client.fetchResource(post.ref.type, post.ref.id,
          include: ['comments']).then((r) {
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
  });
}
