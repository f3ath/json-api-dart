import 'package:json_api/json_api.dart';
import 'package:json_api/src/validation/_validation.dart';
import 'package:test/test.dart';

void main() {
  final apple = ResourceObject('apples', '1');
  final orange = ResourceObject('oranges', '2');
  final cart = ResourceObject('carts', '2', relationships: {
    'goods': ToMany([IdentifierObject('apples', '1')])
  });
  final user = ResourceObject('users', '3', relationships: {
    'carts': ToMany([IdentifierObject('carts', '2')])
  });

  final validator = DocumentValidator();

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
          ToOne(IdentifierObject('apples', '1'), included: [apple])
              .isFullyLinked,
          true);

      expect(ResourceCollectionData([cart], included: [apple]).isFullyLinked,
          true);

      expect(
          ToMany([IdentifierObject('apples', '1')], included: [apple])
              .isFullyLinked,
          true);
    });

    test('An included resource may be identified by another included one', () {
      expect(ResourceData(user, included: [cart, apple]).isFullyLinked, true);
    });
  });

  test('Can not include more that one resource with the same type and id', () {
    final sameApple = ResourceObject(apple.type, apple.id);
    final errors = validator.errors(
        Document(ResourceData(user, included: [apple, cart, sameApple])));
    expect(errors.length, 1);
    expect(
        errors.first.message, 'Resource(apples:1) is included multiple times');
    expect(errors.first.path, '/included');
  });

  test('Can not include primary resource', () {
    final sameUser = ResourceObject(user.type, user.id);
    final errors =
        validator.errors(Document(ResourceData(user, included: [sameUser])));
    expect(errors.length, 1);
    expect(errors.first.message, 'Primary Resource(users:3) is also included');
    expect(errors.first.path, '/included');
  });
}
