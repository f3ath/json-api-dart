import 'dart:convert';

import 'package:http_interop/http_interop.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';

void main() {
  const collection = CollectionTarget('books');
  const resource = ResourceTarget('books', '42');
  const related = RelatedTarget('books', '42', 'authors');
  const relationship = RelationshipTarget('books', '42', 'authors');

  test('resolve decodes and stores the document', () async {
    final httpRequest = Request(
      'post',
      Uri.parse('/books'),
      Body.text('{"data":{"type":"books","attributes":{"title":"Dune"}}}', utf8),
      Headers(),
    );
    final request = await JsonApiRequest.resolve(httpRequest, collection) as CreateResourceRequest;
    expect(request.newResource.type, 'books');
    expect(request.newResource.attributes['title'], 'Dune');
  });

  for (final body in ['{', '[]', 'null', '42']) {
    test('resolve rejects invalid payload $body', () async {
      final request = Request('post', Uri.parse('/books'), Body.text(body, utf8), Headers());
      await expectLater(
        JsonApiRequest.resolve(request, collection),
        throwsA(isA<PayloadInvalid>()),
      );
    });
  }

  final cases = [
    ('get', collection, isA<FetchCollectionRequest>()),
    ('post', collection, isA<CreateResourceRequest>()),
    ('get', resource, isA<FetchResourceRequest>()),
    ('patch', resource, isA<UpdateResourceRequest>()),
    ('delete', resource, isA<DeleteResourceRequest>()),
    ('get', related, isA<FetchRelatedRequest>()),
    ('get', relationship, isA<FetchRelationshipRequest>()),
    ('post', relationship, isA<AddManyRequest>()),
    ('patch', relationship, isA<ReplaceRelationshipRequest>()),
    ('delete', relationship, isA<DeleteManyRequest>()),
  ];

  for (final (method, target) in [
    ('post', collection),
    ('patch', resource),
    ('post', relationship),
    ('patch', relationship),
    ('delete', relationship),
  ]) {
    test('$method ${target.runtimeType} requires a document', () async {
      final request = Request(method, Uri.parse('/books'), Body(), Headers());
      await expectLater(JsonApiRequest.resolve(request, target), throwsA(isA<PayloadMissing>()));
    });
  }

  for (final (method, target, matcher) in cases) {
    test('$method ${target.runtimeType} resolves to the corresponding operation', () async {
      final httpRequest = Request(
        method,
        Uri.parse('/books'),
        Body.text('{"data":null}', utf8),
        Headers(),
      );
      final request = await JsonApiRequest.resolve(httpRequest, target);
      expect(request, matcher);
      expect(request.httpRequest, same(httpRequest));
      expect(request.target, same(target));
      final uppercaseRequest = Request(
        method.toUpperCase(),
        Uri.parse('/books'),
        Body.text('{"data":null}', utf8),
        Headers(),
      );
      expect(await JsonApiRequest.resolve(uppercaseRequest, target), matcher);
    });
  }

  for (final target in [collection, resource, related, relationship]) {
    for (final method in ['get', 'post', 'patch', 'delete', 'put', 'head', 'options']) {
      if (cases.any((entry) => entry.$1 == method && identical(entry.$2, target))) continue;
      test('$method ${target.runtimeType} is not allowed', () async {
        final request = Request(method, Uri.parse('/books'), Body(), Headers());
        await expectLater(
          JsonApiRequest.resolve(request, target),
          throwsA(isA<MethodNotAllowed>().having((error) => error.method, 'method', method)),
        );
      });
    }
  }
}
