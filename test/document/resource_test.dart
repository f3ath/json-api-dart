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

  test('naming', () {
    expect(Resource('_moo', '2').namingViolations().first.path, '/type');
    expect(Resource('_moo', '2').namingViolations().first.value, '_moo');
    expect(
        Resource('apples', '2', meta: {'_foo': 'bar'})
            .namingViolations()
            .first
            .path,
        '/meta');
    expect(
        Resource('apples', '2', meta: {'_foo': 'bar'})
            .namingViolations()
            .first
            .value,
        '_foo');
    expect(
        Resource('apples', '2', attributes: {'_foo': 'bar'})
            .namingViolations()
            .first
            .path,
        '/attributes');
    expect(
        Resource('apples', '2', attributes: {'_foo': 'bar'})
            .namingViolations()
            .first
            .value,
        '_foo');

    expect(
        Resource('articles', '2', toOne: {'_author': Identifier('people', '9')})
            .namingViolations()
            .first
            .path,
        '/relationships');

    expect(
        Resource('articles', '2', toOne: {'author': Identifier('_people', '9')})
            .namingViolations()
            .first
            .path,
        '/relationships/author/type');

    expect(
        Resource('articles', '2', toMany: {'_comments': []})
            .namingViolations()
            .first
            .path,
        '/relationships');

    expect(
        Resource('articles', '2', toMany: {'comments': [Identifier('_moo', '9')]})
            .namingViolations()
            .first
            .path,
        '/relationships/comments/0/type');
  });
}
