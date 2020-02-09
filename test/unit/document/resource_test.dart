import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  test('Removes duplicate identifiers in toMany relationships', () {
    final r = Resource('type', 'id', toMany: {
      'rel': [Identifier('foo', '1'), Identifier('foo', '1')]
    });
    expect(r.toMany['rel'].length, 1);
  });

  test('toString', () {
    expect(Resource('appless', '42', attributes: {'color': 'red'}).toString(),
        'Resource(appless:42 {color: red})');
  });
}
