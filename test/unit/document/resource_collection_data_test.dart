import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('custom links', () {
    test('recognizes custom links', () {
      final r = ResourceCollectionData([],
          links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(r.links['my-link'].toString(), '/my-link');
    });

    test('"links" may contain the "self" key', () {
      final r = ResourceCollectionData([], links: {
        'my-link': Link(Uri.parse('/my-link')),
        'self': Link(Uri.parse('/self')),
      });
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.self.toString(), '/self');
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
