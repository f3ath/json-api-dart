import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_matcher/json_matcher.dart';
import 'package:test/test.dart';

void main() {
  group('ResourceObject', () {
    /// id:null should not be included in JSON
    /// https://jsonapi.org/format/#crud-creating
    test('id:null should not be included in JSON', () {
      final res = ResourceObject('photos', null, attributes: {
        'title': 'Ember Hamster',
        'src': 'http://example.com/images/productivity.png'
      }, relationships: {
        'photographer': ToOne(IdentifierObject('people', '9'))
      });
      expect(
          res,
          encodesToJson({
            "type": "photos",
            "attributes": {
              "title": "Ember Hamster",
              "src": "http://example.com/images/productivity.png"
            },
            "relationships": {
              "photographer": {
                "data": {"type": "people", "id": "9"}
              }
            }
          }));
    });
  });

  group('custom links', () {
    test('recognizes custom links', () {
      final r = ResourceObject('apples', '1',
          links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(r.links['my-link'].toString(), '/my-link');
    });

    test('if passed, "self" argument is merged into "links"', () {
      final r = ResourceObject('apples', '1',
          self: Link(Uri.parse('/self')),
          links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.self.toString(), '/self');
    });

    test('"links" may contain the "self" key', () {
      final r = ResourceObject('apples', '1', links: {
        'my-link': Link(Uri.parse('/my-link')),
        'self': Link(Uri.parse('/self'))
      });
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.self.toString(), '/self');
    });

    test('"self" takes precedence over "links"', () {
      final r =
          ResourceObject('apples', '1', self: Link(Uri.parse('/self')), links: {
        'my-link': Link(Uri.parse('/my-link')),
        'self': Link(Uri.parse('/will-be-replaced'))
      });
      expect(r.links['my-link'].toString(), '/my-link');
      expect(r.links['self'].toString(), '/self');
      expect(r.self.toString(), '/self');
    });

    test('survives json serialization', () {
      final r = ResourceObject('apples', '1', links: {
        'my-link': Link(Uri.parse('/my-link')),
      });
      expect(
          ResourceObject.fromJson(json.decode(json.encode(r)))
              .links['my-link']
              .toString(),
          '/my-link');
    });
  });
}
