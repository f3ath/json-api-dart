import 'dart:convert';

import 'package:json_api/json_api.dart';
import 'package:test/test.dart';

void main() {
  group('custom links', () {
    test('recognizes custom links', () {
      final r = ResourceCollectionData([],
          links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(r.links['my-link'].toString(), '/my-link');
    });

    test('if passed, "self" and "navigation" arguments are merged into "links"',
        () {
      final r = ResourceCollectionData([],
          navigation: Navigation(
              next: Link(Uri.parse('/next')), prev: Link(Uri.parse('/prev'))),
          self: Link(Uri.parse('/self')),
          links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.links['next'].toString(), '/next');
      expect(r.links['prev'].toString(), '/prev');
      expect(r.self.toString(), '/self');
      expect(r.navigation.next.toString(), '/next');
      expect(r.navigation.prev.toString(), '/prev');
    });

    test('"links" may contain the "self" and navigation keys', () {
      final r = ResourceCollectionData([], links: {
        'my-link': Link(Uri.parse('/my-link')),
        'self': Link(Uri.parse('/self')),
        'next': Link(Uri.parse('/next')),
        'prev': Link(Uri.parse('/prev'))
      });
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.links['next'].toString(), '/next');
      expect(r.links['prev'].toString(), '/prev');
      expect(r.self.toString(), '/self');
      expect(r.navigation.next.toString(), '/next');
      expect(r.navigation.prev.toString(), '/prev');
    });

    test('"self" and "navigation" takes precedence over "links"', () {
      final r = ResourceCollectionData([],
          self: Link(Uri.parse('/self')),
          navigation: Navigation(
              next: Link(Uri.parse('/next')), prev: Link(Uri.parse('/prev'))),
          links: {
            'my-link': Link(Uri.parse('/my-link')),
            'self': Link(Uri.parse('/will-be-replaced')),
            'next': Link(Uri.parse('/will-be-replaced')),
            'prev': Link(Uri.parse('/will-be-replaced'))
          });
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.links['next'].toString(), '/next');
      expect(r.links['prev'].toString(), '/prev');
      expect(r.self.toString(), '/self');
      expect(r.navigation.next.toString(), '/next');
      expect(r.navigation.prev.toString(), '/prev');
    });

    test('survives json serialization', () {
      final r = ResourceCollectionData([], links: {
        'my-link': Link(Uri.parse('/my-link')),
      });
      expect(
          ResourceCollectionData.fromJson(json.decode(json.encode(r)))
              .links['my-link']
              .toString(),
          '/my-link');
    });
  });
}
