import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('custom links', () {
    test('recognizes custom links', () {
      final r = ToOne(null, links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(r.links['my-link'].toString(), '/my-link');
    });

    test('if passed, "related" and "self" arguments are merged into "links"',
        () {
      final r = ToOne(null,
          related: Link(Uri.parse('/related')),
          self: Link(Uri.parse('/self')),
          links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.links['related'].toString(), '/related');
    });

    test('"links" may contain the "related" and "self" keys', () {
      final r = ToOne(null, links: {
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

    test('"related" and "self" take precedence over "links"', () {
      final r = ToOne(null,
          self: Link(Uri.parse('/self')),
          related: Link(Uri.parse('/related')),
          links: {
            'my-link': Link(Uri.parse('/my-link')),
            'related': Link(Uri.parse('/will-be-replaced')),
            'self': Link(Uri.parse('/will-be-replaced'))
          });
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.links['related'].toString(), '/related');
      expect(r.self.toString(), '/self');
      expect(r.related.toString(), '/related');
    });

    test('custom "links" survives json serialization', () {
      final r = ToOne(null, links: {
        'my-link': Link(Uri.parse('/my-link')),
      });
      expect(
          ToOne.fromJson(json.decode(json.encode(r)))
              .links['my-link']
              .toString(),
          '/my-link');
    });
  });
}
