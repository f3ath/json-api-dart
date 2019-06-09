import 'package:json_api/json_api.dart';
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
        'photographer': ToOne(IdentifierObject(Identifier('people', '9')))
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
}
