import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  test('Removes duplicate identifiers in toMany relationships', () {
    final r = Resource('type', 'id', toMany: {
      'rel': [Identifier('foo', '1'), Identifier('foo', '1')]
    });
    expect(r.many('rel').length, 1);
  });

  test('toString', () {
    expect(Resource('apples', '42').toString(), 'Resource(apples:42)');
  });
}
