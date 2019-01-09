import 'dart:convert';
import 'dart:io';

import 'package:json_api/json_api.dart';
import 'package:json_api_document/json_api_document.dart';
import 'package:test/test.dart';

final appleResource = Resource('apples', '42');

expectSame(Document expected, Document actual) =>
    expect(json.encode(expected), json.encode(actual));

void main() {
  final client = JsonApiClient(baseUrl: 'http://localhost:4041');
  HttpServer server;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 4041);
  });

  tearDown(() async {
    server.close(force: true);
  });

  group('fetchResource()', () {
    test('200 with a document', () async {
      final doc = DataDocument.fromResource(appleResource);

      server.listen((rq) {
        expect(rq.method, 'GET');
        expect(rq.headers['foo'], ['bar']);
        expect(rq.uri.path, '/fetch');
        expect(rq.headers.host, 'localhost');
        expect(rq.headers.port, 4041);
        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        rq.response.write(json.encode(doc));
        rq.response.close();
      });

      final result =
          await client.fetchResource('/fetch', headers: {'foo': 'bar'});
      expectSame(doc, result.document);
      expect(
          (result.document as DataDocument).data, TypeMatcher<ResourceData>());
      expect(result.status, HttpStatus.ok);
    });

    test('404 without a document', () async {
      server.listen((rq) {
        rq.response.statusCode = HttpStatus.notFound;
        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        rq.response.close();
      });
      final result = await client.fetchResource('/fetch');
      expect(result.document, isNull);
      expect(result.status, HttpStatus.notFound);
    });

    test('invalid Content-Type', () async {
      server.listen((rq) {
        rq.response.close();
      });
      expect(() async => await client.fetchResource('/fetch'),
          throwsA(TypeMatcher<InvalidContentTypeException>()));
    });
  }, tags: ['vm-only']);

  ///

  group('deleteResource()', () {
    test('200 with a meta document', () async {
      final doc = MetaDocument({"test": "test"});

      server.listen((rq) {
        expect(rq.method, 'DELETE');
        expect(rq.headers['foo'], ['bar']);
        expect(rq.uri.path, '/delete');
        expect(rq.headers.host, 'localhost');
        expect(rq.headers.port, 4041);
        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        rq.response.write(json.encode(doc));
        rq.response.close();
      });

      final result =
          await client.deleteResource('/delete', headers: {'foo': 'bar'});
      expect(result.document.meta['test'], 'test');
      expect(result.status, HttpStatus.ok);
    });

    test('404 without a document', () async {
      server.listen((rq) {
        rq.response.statusCode = HttpStatus.notFound;
        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        rq.response.close();
      });
      final result = await client.deleteResource('/delete');
      expect(result.document, isNull);
      expect(result.status, HttpStatus.notFound);
    });

    test('invalid Content-Type', () async {
      server.listen((rq) {
        rq.response.close();
      });
      expect(() async => await client.deleteResource('/delete'),
          throwsA(TypeMatcher<InvalidContentTypeException>()));
    });
  }, tags: ['vm-only']);

  ///

  group('createResource()', () {
    test('201 created', () async {
      server.listen((rq) async {
        expect(rq.method, 'POST');
        expect(rq.headers['foo'], ['bar']);
        expect(rq.headers.contentType.value, startsWith(Document.mediaType));
        expect(rq.headers['accept'].first, startsWith(Document.mediaType));
        expect(rq.uri.path, '/create');
        expect(rq.headers.host, 'localhost');
        expect(rq.headers.port, 4041);
        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        final doc = Document.fromJson(json.decode(await utf8.decodeStream(rq)));
        rq.response.statusCode = HttpStatus.created;
        rq.response.headers.add('location', 'http://example.com/');
        rq.response.write(json.encode(doc));
        rq.response.close();
      });

      final result = await client
          .createResource('/create', appleResource, headers: {'foo': 'bar'});
      expect(result.document, TypeMatcher<DataDocument>());
      expect((result.document as DataDocument).data.resources.first.toJson(),
          appleResource.toJson());
      expect(result.location, 'http://example.com/');
      expect(result.status, HttpStatus.created);
    });

    test('202 accepted', () async {
      server.listen((rq) async {
        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        rq.response.statusCode = HttpStatus.accepted;
        rq.response.close();
      });

      final result = await client.createResource('/create', appleResource);
      expect(result.document, isNull);
      expect(result.status, HttpStatus.accepted);
    });

    test('invalid Content-Type', () async {
      server.listen((rq) {
        rq.response.close();
      });

      expect(() async => await client.createResource('/test', appleResource),
          throwsA(TypeMatcher<InvalidContentTypeException>()));
    });
  }, tags: ['vm-only']);

  ///

  group('updateResource()', () {
    test('200 ok', () async {
      server.listen((rq) async {
        expect(rq.method, 'PATCH');
        expect(rq.headers['foo'], ['bar']);
        expect(rq.headers.contentType.value, startsWith(Document.mediaType));
        expect(rq.headers['accept'].first, startsWith(Document.mediaType));
        expect(rq.uri.path, '/create');
        expect(rq.headers.host, 'localhost');
        expect(rq.headers.port, 4041);
        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        final doc = Document.fromJson(json.decode(await utf8.decodeStream(rq)));
        rq.response.statusCode = HttpStatus.created;
        rq.response.headers.add('location', 'http://example.com/');
        rq.response.write(json.encode(doc));
        rq.response.close();
      });

      final result = await client
          .updateResource('/create', appleResource, headers: {'foo': 'bar'});
      expect(result.document, TypeMatcher<DataDocument>());
      expect((result.document as DataDocument).data.resources.first.toJson(),
          appleResource.toJson());
      expect(result.location, 'http://example.com/');
      expect(result.status, HttpStatus.created);
    });

    test('202 accepted', () async {
      server.listen((rq) async {
        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        rq.response.statusCode = HttpStatus.accepted;
        rq.response.close();
      });

      final result = await client.updateResource('/create', appleResource);
      expect(result.document, isNull);
      expect(result.status, HttpStatus.accepted);
    });

    test('invalid Content-Type', () async {
      server.listen((rq) {
        rq.response.close();
      });

      expect(() async => await client.updateResource('/test', appleResource),
          throwsA(TypeMatcher<InvalidContentTypeException>()));
    });
  }, tags: ['vm-only']);

  ///

  group('fetchRelationship()', () {
    test('200 with a document', () async {
      final doc = DataDocument.fromResource(appleResource);

      server.listen((rq) {
        expect(rq.method, 'GET');
        expect(rq.headers['foo'], ['bar']);
        expect(rq.uri.path, '/fetch');
        expect(rq.headers.host, 'localhost');
        expect(rq.headers.port, 4041);
        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        rq.response.write(json.encode(doc));
        rq.response.close();
      });

      final result =
          await client.fetchRelationship('/fetch', headers: {'foo': 'bar'});
      expectSame(doc, result.document);
      expect((result.document as DataDocument).data,
          TypeMatcher<IdentifierData>());

      expect(result.status, HttpStatus.ok);
    }, tags: ['vm-only']);

    test('404 without a document', () async {
      server.listen((rq) {
        rq.response.statusCode = HttpStatus.notFound;
        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        rq.response.close();
      });
      final result = await client.fetchRelationship('/fetch');
      expect(result.document, isNull);
      expect(result.status, HttpStatus.notFound);
    });

    test('invalid Content-Type', () async {
      server.listen((rq) {
        rq.response.close();
      });
      expect(() async => await client.fetchRelationship('/fetch'),
          throwsA(TypeMatcher<InvalidContentTypeException>()));
    });
  }, tags: ['vm-only']);

  ///

  group('setToOne()', () {
    final identifier = Identifier('apples', '42');

    test('200', () async {
      server.listen((rq) async {
        expect(rq.method, 'PATCH');
        expect(rq.headers['foo'], ['bar']);
        expect(rq.uri.path, '/update');
        expect(rq.headers.host, 'localhost');
        expect(rq.headers.port, 4041);
        final doc = Document.fromJson(json.decode(await utf8.decodeStream(rq)));
        expect(doc, TypeMatcher<DataDocument>());
        expect((doc as DataDocument).data, TypeMatcher<IdentifierData>());
        expect((doc as DataDocument).data.identifies(Resource('apples', '42')),
            true);

        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        rq.response.close();
      });

      final result = await client
          .setToOne('/update', identifier, headers: {'foo': 'bar'});

      expect(result.status, HttpStatus.ok);
    }, tags: ['vm-only']);

    test('invalid Content-Type', () async {
      server.listen((rq) {
        rq.response.close();
      });
      expect(() async => await client.setToOne('/update', identifier),
          throwsA(TypeMatcher<InvalidContentTypeException>()));
    });
  }, tags: ['vm-only']);

  ///

  group('deleteToOne()', () {

    test('200', () async {
      server.listen((rq) async {
        expect(rq.method, 'PATCH');
        expect(rq.headers['foo'], ['bar']);
        expect(rq.uri.path, '/update');
        expect(rq.headers.host, 'localhost');
        expect(rq.headers.port, 4041);
        final doc = Document.fromJson(json.decode(await utf8.decodeStream(rq)));
        expect(doc, TypeMatcher<DataDocument>());
        expect((doc as DataDocument).data, TypeMatcher<NullData>());

        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        rq.response.close();
      });

      final result = await client
          .deleteToOne('/update', headers: {'foo': 'bar'});

      expect(result.status, HttpStatus.ok);
    }, tags: ['vm-only']);

    test('invalid Content-Type', () async {
      server.listen((rq) {
        rq.response.close();
      });
      expect(() async => await client.deleteToOne('/update'),
          throwsA(TypeMatcher<InvalidContentTypeException>()));
    });
  }, tags: ['vm-only']);

  ///

  group('setToMany()', () {
    final apple1 = Identifier('apples', '1');
    final apple2 = Identifier('apples', '2');

    test('200', () async {
      server.listen((rq) async {
        expect(rq.method, 'PATCH');
        expect(rq.headers['foo'], ['bar']);
        expect(rq.uri.path, '/update');
        expect(rq.headers.host, 'localhost');
        expect(rq.headers.port, 4041);
        final doc = Document.fromJson(json.decode(await utf8.decodeStream(rq)));
        expect(doc, TypeMatcher<DataDocument>());
        expect((doc as DataDocument).data, TypeMatcher<IdentifierListData>());
        expect((doc as DataDocument).data.identifies(Resource('apples', '1')),
            true);
        expect((doc as DataDocument).data.identifies(Resource('apples', '2')),
            true);

        rq.response.headers.contentType = ContentType.parse(Document.mediaType);
        rq.response.close();
      });

      final result = await client
          .setToMany('/update', [apple1, apple2], headers: {'foo': 'bar'});

      expect(result.status, HttpStatus.ok);
    }, tags: ['vm-only']);

    test('invalid Content-Type', () async {
      server.listen((rq) {
        rq.response.close();
      });
      expect(() async => await client.setToMany('/update', [apple1, apple2]),
          throwsA(TypeMatcher<InvalidContentTypeException>()));
    });
  }, tags: ['vm-only']);


}
