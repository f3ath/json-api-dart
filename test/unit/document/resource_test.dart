import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  test('can add id to existing resource', () {
    final r0 = Resource('carts', null, attributes: {
      'name': 'Gifts'
    }, toOne: {
      'market': Identifier('markets', '1')
    }, toMany: {
      'goods': [Identifier('books', '1'), Identifier('books', '2')]
    });

    final r1 = r0.withId('123');

    expect(r1.type, r0.type);
    expect(r1.id, '123');
    expect(r1.attributes, r0.attributes);
    expect(r1.toOne, r0.toOne);
    expect(r1.toMany, r0.toMany);

    expect(r0.id, isNull);
  });
}
