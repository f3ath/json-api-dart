import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/handler.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import 'shared.dart';

void main() {
  Handler<HttpRequest, HttpResponse> server;
  JsonApiClient client;

  setUp(() async {
    server = initServer();
    client = JsonApiClient(RecommendedUrlDesign.pathOnly, httpHandler: server);
  });

  group('CRUD', () {
    Resource alice;
    Resource bob;
    Resource post;
    Resource comment;
    Resource secretComment;

    setUp(() async {
      alice = (await client.createNew('users', attributes: {'name': 'Alice'}))
          .resource;
      bob = (await client.createNew('users', attributes: {'name': 'Bob'}))
          .resource;
      post = (await client.createNew('posts',
              attributes: {'title': 'Hello world'},
              one: {'author': alice.toIdentifier()}))
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
      final response = await client.fetchCollection('posts',
          include: ['author', 'comments', 'comments.author']);

      expect(response.http.statusCode, 200);
      expect(response.collection.length, 1);
      expect(response.included.length, 3);

      final fetchedPost = response.collection.first;
      expect(fetchedPost.attributes['title'], 'Hello world');

      final fetchedAuthor = response.included[fetchedPost.one('author').key];
      expect(fetchedAuthor.attributes['name'], 'Alice');

      final fetchedComment =
          response.included[fetchedPost.many('comments').single.key];
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
        expect(r.resource.attributes['name'], 'Alice');
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
      await client.fetchOne(post.type, post.id, 'author').then((r) {
        expect(r.relationship.identifier.id, alice.id);
      });
    });

    test('Fetch a to-many relationship', () async {
      await client.fetchMany(post.type, post.id, 'comments').then((r) {
        expect(r.relationship.single.id, comment.id);
      });
    });

    test('Delete a to-one relationship', () async {
      await client.deleteOne(post.type, post.id, 'author');
      await client
          .fetchResource(post.type, post.id, include: ['author']).then((r) {
        expect(r.resource.one('author'), isEmpty);
      });
    });

    test('Replace a to-one relationship', () async {
      await client.replaceOne(post.type, post.id, 'author', bob.toIdentifier());
      await client
          .fetchResource(post.type, post.id, include: ['author']).then((r) {
        expect(
            r.included[r.resource.one('author').key].attributes['name'], 'Bob');
      });
    });

    test('Delete from a to-many relationship', () async {
      await client
          .deleteMany(post.type, post.id, 'comments', [comment.toIdentifier()]);
      await client.fetchResource(post.type, post.id).then((r) {
        expect(r.resource.many('comments'), isEmpty);
      });
    });

    test('Replace a to-many relationship', () async {
      await client.replaceMany(
          post.type, post.id, 'comments', [secretComment.toIdentifier()]);
      await client
          .fetchResource(post.type, post.id, include: ['comments']).then((r) {
        expect(
            r.included[r.resource.many('comments').single.key]
                .attributes['text'],
            'Secret comment');
      });
    });
  });
}
