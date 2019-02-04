import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/validation.dart';
import 'package:json_matcher/json_matcher.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    final id = Identifier('apples', '2');
    expect(id.type, 'apples');
    expect(id.id, '2');
    expect(id.meta, isEmpty);

    expect(() => Identifier(null, '1'), throwsArgumentError);
    expect(() => Identifier('foos', null), throwsArgumentError);
  });

  test('.toJson()', () {
    expect(Identifier('apples', '2'),
        encodesToJson({'type': 'apples', 'id': '2'}));
    expect(
        Identifier('apples', '2', meta: {'foo': 'bar'}),
        encodesToJson({
          'type': 'apples',
          'id': '2',
          'meta': {'foo': 'bar'}
        }));
  });

  test('.fromJson()', () {
    final j1 = {'type': 'apples', 'id': '2'};
    expect(Identifier.fromJson(j1), encodesToJson(j1));

    final j2 = {
      'type': 'apples',
      'id': '2',
      'meta': {'foo': 'bar'}
    };
    expect(Identifier.fromJson(j2), encodesToJson(j2));
  });

  test('naming', () {
    expect(Identifier('_moo', '2').validate(StandardNaming()).first.pointer,
        '/type');
    expect(
        Identifier('_moo', '2').validate(StandardNaming()).first.value, '_moo');
    expect(
        Identifier('apples', '2', meta: {'_foo': 'bar'})
            .validate(StandardNaming())
            .first
            .pointer,
        '/meta');
    expect(
        Identifier('apples', '2', meta: {'_foo': 'bar'})
            .validate(StandardNaming())
            .first
            .value,
        '_foo');
  });
}
