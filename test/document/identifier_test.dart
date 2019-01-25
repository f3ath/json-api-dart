import 'package:json_api/document.dart';
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
    expect(Identifier('apples', '2').toJson(), {'type': 'apples', 'id': '2'});
    expect(Identifier('apples', '2', meta: {'foo': 'bar'}).toJson(), {
      'type': 'apples',
      'id': '2',
      'meta': {'foo': 'bar'}
    });
  });

  test('.fromJson()', () {
    final j1 = {'type': 'apples', 'id': '2'};
    expect(Identifier.fromJson(j1).toJson(), j1);

    final j2 = {
      'type': 'apples',
      'id': '2',
      'meta': {'foo': 'bar'}
    };
    expect(Identifier.fromJson(j2).toJson(), j2);
  });

  test('naming', () {
    expect(Identifier('_moo', '2').namingViolations().first.path, '/type');
    expect(Identifier('_moo', '2').namingViolations().first.value, '_moo');
    expect(
        Identifier('apples', '2', meta: {'_foo': 'bar'})
            .namingViolations()
            .first
            .path,
        '/meta');
    expect(
        Identifier('apples', '2', meta: {'_foo': 'bar'})
            .namingViolations()
            .first
            .value,
        '_foo');
  });

}
