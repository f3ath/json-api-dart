import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('custom links', () {
    test('recognizes custom links', () {
      final r = ToMany([], links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(r.links['my-link'].toString(), '/my-link');
    });

    test('"links" may contain the "related" and "self" keys', () {
      final r = ToMany([], links: {
        'my-link': Link(Uri.parse('/my-link')),
        'related': Link(Uri.parse('/related')),
        'self': Link(Uri.parse('/self'))
      });
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.links['related'].toString(), '/related');
      expect(r.self.toString(), '/self');
      expect(r.related.toString(), '/related');
    });

    test('custom "links" survives json serialization', () {
      final r = ToMany([], links: {
        'my-link': Link(Uri.parse('/my-link')),
      });
      expect(
          ToMany.fromJson(json.decode(json.encode(r)))
              .links['my-link']
              .toString(),
          '/my-link');
    });
  });

  group('fromJson()', () {
    test('if no links is present, the "links" property is null', () {
      final r = Relationship.fromJson(json.decode(json.encode((ToMany([])))));
      expect(r.links, null);
      expect(r.self, null);
    });
  });
}
