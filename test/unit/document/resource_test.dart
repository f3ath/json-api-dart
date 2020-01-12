import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  test('Can not create Identifier when id==null', () {
    expect(() => Resource('type', null).toIdentifier(), throwsStateError);
  });

  test('Can create Identifier', () {
    final id = Resource('apples', '123').toIdentifier();
    expect(id.type, 'apples');
    expect(id.id, '123');
  });

  test('Has key', () {
    expect(Resource('apples', '123').key, 'apples:123');
    expect(Resource('apples', null).key, 'apples:null');
  });
}
