import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    final id = Resource('apples', '2');
    expect(id.type, 'apples');
    expect(id.id, '2');
    expect(id.meta, isEmpty);

    expect(() => Resource(null, '1'), throwsArgumentError);
    expect(Resource('foos', null).id, isNull);
  });

  test('.toJson()', () {
    final url = 'http://example.com/apples/2';
    expect(Resource('apples', '2').toJson(), {'type': 'apples', 'id': '2'});
    expect(
        Resource('apples', '2',
                attributes: {'color': 'red'},
                meta: {'foo': 'bar'},
                self: Link(url))
            .toJson(),
        {
          'type': 'apples',
          'id': '2',
          'attributes': {'color': 'red'},
          'links': {'self': url},
          'meta': {'foo': 'bar'}
        });
  });

  test('.fromJson()', () {
    final j1 = {'type': 'apples', 'id': '2'};
    expect(Resource.fromJson(j1).toJson(), j1);

    final j2 = {
      'type': 'apples',
      'id': '2',
      'meta': {'foo': 'bar'}
    };
    expect(Resource.fromJson(j2).toJson(), j2);
  });

  test('validation', () {
    expect(Resource('_moo', '2').validate().first.pointer, '/type');
    expect(Resource('_moo', '2').validate().first.value, '_moo');
    expect(
        Resource('apples', '2', meta: {'_foo': 'bar'}).validate().first.pointer,
        '/meta');
    expect(
        Resource('apples', '2', meta: {'_foo': 'bar'}).validate().first.value,
        '_foo');
    expect(
        Resource('apples', '2', attributes: {'_foo': 'bar'})
            .validate()
            .first
            .pointer,
        '/attributes');
    expect(
        Resource('apples', '2', attributes: {'_foo': 'bar'})
            .validate()
            .first
            .value,
        '_foo');

    expect(
        Resource('articles', '2', toOne: {'_author': Identifier('people', '9')})
            .validate()
            .first
            .pointer,
        '/relationships');

    expect(
        Resource('articles', '2', toOne: {'author': Identifier('_people', '9')})
            .validate()
            .first
            .pointer,
        '/relationships/author/type');

    expect(
        Resource('articles', '2', toMany: {'_comments': []})
            .validate()
            .first
            .pointer,
        '/relationships');

    expect(
        Resource('articles', '2', toMany: {'type': []})
            .validate()
            .first
            .pointer,
        '/relationships');

    expect(
        Resource('articles', '2',
            toMany: {'foo': []},
            attributes: {'foo': 'bar'}).validate().first.pointer,
        '/fields');
  });
}
