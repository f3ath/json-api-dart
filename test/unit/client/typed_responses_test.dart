import 'package:http_interop/http_interop.dart' as i;
import 'package:json_api/client.dart';
import 'package:json_api/src/client/response.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final emptyResponse = Response(i.Response(200, i.Body(), i.Headers()), null);
  group('CollectionFetched', () {
    test('throws on empty body', () {
      expect(() => CollectionFetched(emptyResponse), throwsFormatException);
    });
  });

  group('RelatedResourceFetched', () {
    test('throws on empty body', () {
      expect(
          () => RelatedResourceFetched(emptyResponse), throwsFormatException);
    });
  });

  group('RelationshipFetched', () {
    test('.many() throws on empty body', () {
      expect(
          () => RelationshipFetched.many(emptyResponse), throwsFormatException);
    });

    test('.one() throws on empty body', () {
      expect(
          () => RelationshipFetched.one(emptyResponse), throwsFormatException);
    });
  });

  group('ResourceCreated', () {
    test('throws on empty body', () {
      expect(() => ResourceCreated(emptyResponse), throwsFormatException);
    });
  });

  group('ResourceFetched', () {
    test('throws on empty body', () {
      expect(() => ResourceFetched(emptyResponse), throwsFormatException);
    });
  });
}
