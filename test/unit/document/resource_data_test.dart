import 'dart:convert';

import 'package:json_api/json_api.dart';
import 'package:test/test.dart';

void main() {
  test('Can decode a primary resource with missing id', () {
    final data = ResourceData.fromJson(json.decode(json.encode({
      'data': {'type': 'apples'}
    })));
    expect(data.unwrap().type, 'apples');
    expect(data.unwrap().id, isNull);
  });

  test('Can decode a primary resource with null id', () {
    final data = ResourceData.fromJson(json.decode(json.encode({
      'data': {'type': 'apples', 'id': null}
    })));
    expect(data.unwrap().type, 'apples');
    expect(data.unwrap().id, isNull);
  });

  group('custom links', () {
    test('recognizes custom links', () {
      final r =
          ResourceData(null, links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(r.links['my-link'].toString(), '/my-link');
    });

    test('if passed, "self" argument is merged into "links"', () {
      final r = ResourceData(null,
          self: Link(Uri.parse('/self')),
          links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.self.toString(), '/self');
    });

    test('"links" may contain the "self" key', () {
      final r = ResourceData(null, links: {
        'my-link': Link(Uri.parse('/my-link')),
        'self': Link(Uri.parse('/self'))
      });
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.self.toString(), '/self');
    });

    test('"self" takes precedence over "links"', () {
      final r = ResourceData(null, self: Link(Uri.parse('/self')), links: {
        'my-link': Link(Uri.parse('/my-link')),
        'self': Link(Uri.parse('/will-be-replaced'))
      });
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.self.toString(), '/self');
    });

    test('survives json serialization', () {
      final r = ResourceData(null, links: {
        'my-link': Link(Uri.parse('/my-link')),
      });
      expect(
          ResourceData.fromJson(json.decode(json.encode(r)))
              .links['my-link']
              .toString(),
          '/my-link');
    });
  });
}
