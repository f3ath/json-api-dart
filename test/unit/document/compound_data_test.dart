import 'package:json_api/json_api.dart';
import 'package:test/test.dart';

void main() {
  final apple = ResourceObject('apples', '1');
  final orange = ResourceObject('oranges', '2');
  final cart = ResourceObject('carts', '2', relationships: {
    'goods': ToMany([IdentifierObject(Identifier('apples', '1'))])
  });
  final user = ResourceObject('users', '3', relationships: {
    'carts': ToMany([IdentifierObject(Identifier('carts', '2'))])
  });

  group('Full linkage', () {
    test('A document without included resources is fully linked', () {
      final data = ResourceData(apple);
      expect(data.isFullyLinked, true);
    });

    test('An empty document with a linked resource is not fully linked', () {
      expect(
          ResourceCollectionData([], included: [orange]).isFullyLinked, false);
      expect(ToMany([], included: [orange]).isFullyLinked, false);
      expect(ToOne(null, included: [orange]).isFullyLinked, false);
    });

    test('An included resource may be identified by primary data', () {
      expect(ResourceData(cart, included: [apple]).isFullyLinked, true);

      expect(
          ToOne(IdentifierObject(Identifier('apples', '1')), included: [apple])
              .isFullyLinked,
          true);

      expect(ResourceCollectionData([cart], included: [apple]).isFullyLinked,
          true);

      expect(
          ToMany([IdentifierObject(Identifier('apples', '1'))],
              included: [apple]).isFullyLinked,
          true);
    });

    test('An included resource may be identified by another included one', () {
      expect(ResourceData(user, included: [cart, apple]).isFullyLinked, true);
    });
  });
}
