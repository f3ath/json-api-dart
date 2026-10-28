import 'package:http_interop/http_interop.dart';
import 'package:json_api/http.dart';
import 'package:json_api/server.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final get = Request('GET', Uri(), Body.empty(), Headers());

  group('default handlers', () {
    final converter = errorConverter();
    test('can catch MethodNotAllowed', () async {
      final r = await converter((_) => throw MethodNotAllowed('foo'))(get);
      expect(r.statusCode, equals(StatusCode.methodNotAllowed));
    });
    test('can catch UnmatchedTarget', () async {
      final r = await converter((_) => throw UnmatchedTarget(Uri()))(get);
      expect(r.statusCode, equals(StatusCode.badRequest));
    });
    test('can catch CollectionNotFound', () async {
      final r = await converter((_) => throw CollectionNotFound('foo'))(get);
      expect(r.statusCode, equals(StatusCode.notFound));
    });
    test('can catch ResourceNotFound', () async {
      final r = await converter((_) => throw ResourceNotFound('foo', 'bar'))(get);
      expect(r.statusCode, equals(StatusCode.notFound));
    });
    test('can catch RelationshipNotFound', () async {
      final r = await converter((_) => throw RelationshipNotFound('foo', 'bar', 'baz'))(get);
      expect(r.statusCode, equals(StatusCode.notFound));
    });
    test('can catch UnsupportedMediaType', () async {
      final r = await converter((_) => throw UnsupportedMediaType())(get);
      expect(r.statusCode, equals(StatusCode.unsupportedMediaType));
    });
    test('can catch Unacceptable', () async {
      final r = await converter((_) => throw NotAcceptable())(get);
      expect(r.statusCode, equals(StatusCode.notAcceptable));
    });
    test('can catch any other error', () async {
      final r = await converter((_) => throw 'foo')(get);
      expect(r.statusCode, equals(StatusCode.internalServerError));
    });
  });

  group('custom handlers', () {
    final converter = errorConverter(
      onMethodNotAllowed: (_) async => Response(550, Body.empty(), Headers()),
      onUnmatchedTarget: (_) async => Response(551, Body.empty(), Headers()),
      onCollectionNotFound: (_) async => Response(552, Body.empty(), Headers()),
      onResourceNotFound: (_) async => Response(553, Body.empty(), Headers()),
      onRelationshipNotFound: (_) async => Response(554, Body.empty(), Headers()),
      onError: (_, _) async => Response(555, Body.empty(), Headers()),
    );
    test('can catch MethodNotAllowed', () async {
      final r = await converter((_) => throw MethodNotAllowed('foo'))(get);
      expect(r.statusCode, equals(550));
    });
    test('can catch UnmatchedTarget', () async {
      final r = await converter((_) => throw UnmatchedTarget(Uri()))(get);
      expect(r.statusCode, equals(551));
    });
    test('can catch CollectionNotFound', () async {
      final r = await converter((_) => throw CollectionNotFound('foo'))(get);
      expect(r.statusCode, equals(552));
    });
    test('can catch ResourceNotFound', () async {
      final r = await converter((_) => throw ResourceNotFound('foo', 'bar'))(get);
      expect(r.statusCode, equals(553));
    });
    test('can catch RelationshipNotFound', () async {
      final r = await converter((_) => throw RelationshipNotFound('foo', 'bar', 'baz'))(get);
      expect(r.statusCode, equals(554));
    });
    test('can catch any other error', () async {
      final r = await converter((_) => throw 'foo')(get);
      expect(r.statusCode, equals(555));
    });
  });
}
