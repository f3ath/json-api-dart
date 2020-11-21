import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/_demo/demo_server.dart';
import 'package:json_api/src/_demo/in_memory_repo.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  JsonApiClient client;
  DemoServer server;

  setUp(() async {
    final repo = InMemoryRepo(['users', 'posts', 'comments']);
    server = DemoServer(repo, port: 8123);
    await server.start();
    client = JsonApiClient(DartHttp(), RecommendedUrlDesign(server.uri));
  });

  tearDown(() async {
    await server.stop();
  });

  group('Use cases', () {
    group('Resource creation', () {
      test('Resource id assigned on the server', () async {
        final r = await client(
            Request.createNew('posts', attributes: {'title': 'Hello world'}));
        expect(r.http.statusCode, 201);
        // TODO: Why does "Location" header not work in browsers?
        expect(r.http.headers['location'], '/posts/${r.resource.id}');
        expect(r.links['self'].toString(), '/posts/${r.resource.id}');
        expect(r.resource.type, 'posts');
        expect(r.resource.id, isNotEmpty);
        expect(r.resource.attributes['title'], 'Hello world');
        expect(r.resource.links['self'].toString(), '/posts/${r.resource.id}');
      });
      test('Resource id assigned on the client', () async {
        final id = Uuid().v4();
        final r = await client(
            Request.create('posts', id, attributes: {'title': 'Hello world'}));
        expect(r.http.statusCode, 204);
        expect(r.resource, isNull);
        expect(r.http.headers['location'], isNull);
      });
    });

    group('CRUD', () {
      Resource alice;
      Resource bob;
      Resource post;
      Resource comment;
      Resource secretComment;

      setUp(() async {
        alice = (await client(
                Request.createNew('users', attributes: {'name': 'Alice'})))
            .resource;
        bob = (await client(
                Request.createNew('users', attributes: {'name': 'Bob'})))
            .resource;
        post = (await client(Request.createNew('posts',
                attributes: {'title': 'Hello world'},
                one: {'author': alice.toIdentifier()})))
            .resource;
        comment = (await client(Request.createNew('comments',
                attributes: {'text': 'Hi Alice'},
                one: {'author': bob.toIdentifier()})))
            .resource;
        secretComment = (await client(Request.createNew('comments',
                attributes: {'text': 'Secret comment'},
                one: {'author': bob.toIdentifier()})))
            .resource;
        await client(Request.addMany(
            post.type, post.id, 'comments', [comment.toIdentifier()]));
      });

      test('Fetch a complex resource', () async {
        final response = await client(Request.fetchCollection('posts')
          ..include(['author', 'comments', 'comments.author']));

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

      test('Fetch a to-one relationship', () async {
        final r = await client(
            Request.fetchOne(post.type, post.id, 'author'));
        expect(r.relationship.identifier.id, alice.id);
      });

      test('Fetch a to-many relationship', () async {
        final r = await client(
            Request.fetchMany(post.type, post.id, 'comments'));
        expect(r.relationship.single.id, comment.id);
      });

      test('Delete a to-one relationship', () async {
        await client(Request.deleteOne(post.type, post.id, 'author'));
        final r = await client(
            Request.fetchResource(post.type, post.id)..include(['author']));
        expect(r.resource.one('author'), isEmpty);
      });

      test('Replace a to-one relationship', () async {
        await client(Request.replaceOne(
            post.type, post.id, 'author', bob.toIdentifier()));
        final r = await client(
            Request.fetchResource(post.type, post.id)..include(['author']));
        expect(
            r.included[r.resource.one('author').key].attributes['name'], 'Bob');
      });

      test('Delete from a to-many relationship', () async {
        await client(Request.deleteMany(
            post.type, post.id, 'comments', [comment.toIdentifier()]));
        final r = await client(Request.fetchResource(post.type, post.id));
        expect(r.resource.many('comments'), isEmpty);
      });

      test('Replace a to-many relationship', () async {
        await client(Request.replaceMany(
            post.type, post.id, 'comments', [secretComment.toIdentifier()]));
        final r = await client(
            Request.fetchResource(post.type, post.id)..include(['comments']));
        expect(
            r.included[r.resource.many('comments').single.key]
                .attributes['text'],
            'Secret comment');
      });
    });
  }, testOn: 'vm');
}
