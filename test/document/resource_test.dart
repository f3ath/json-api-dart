import 'package:json_api/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/validation.dart';
import 'package:json_matcher/json_matcher.dart';
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
    expect(
        Resource('apples', '2'), encodesToJson({'type': 'apples', 'id': '2'}));
    expect(
        Resource('apples', '2',
            attributes: {'color': 'red'}, meta: {'foo': 'bar'}),
        encodesToJson({
          'type': 'apples',
          'id': '2',
          'attributes': {'color': 'red'},
          'meta': {'foo': 'bar'}
        }));
  });

  test('.fromJson()', () {
    final j1 = {'type': 'apples', 'id': '2'};
    expect(Resource.fromJson(j1), encodesToJson(j1));

    final j2 = {
      'type': 'apples',
      'id': '2',
      'meta': {'foo': 'bar'}
    };
    expect(Resource.fromJson(j2), encodesToJson(j2));
  });

  test('validation', () {
    expect(Resource('_moo', '2').validate(StandardNaming()).first.pointer,
        '/type');
    expect(
        Resource('_moo', '2').validate(StandardNaming()).first.value, '_moo');
    expect(
        Resource('apples', '2', meta: {'_foo': 'bar'})
            .validate(StandardNaming())
            .first
            .pointer,
        '/meta');
    expect(
        Resource('apples', '2', meta: {'_foo': 'bar'})
            .validate(StandardNaming())
            .first
            .value,
        '_foo');
    expect(
        Resource('apples', '2', attributes: {'_foo': 'bar'})
            .validate(StandardNaming())
            .first
            .pointer,
        '/attributes');
    expect(
        Resource('apples', '2', attributes: {'_foo': 'bar'})
            .validate(StandardNaming())
            .first
            .value,
        '_foo');

    expect(
        Resource('articles', '2',
                relationships: {'_author': ToOne(Identifier('people', '9'))})
            .validate(StandardNaming())
            .first
            .pointer,
        '/relationships');

    expect(
        Resource('articles', '2',
                relationships: {'author': ToOne(Identifier('_people', '9'))})
            .validate(StandardNaming())
            .first
            .pointer,
        '/relationships/author/type');

    expect(
        Resource('articles', '2', relationships: {'_comments': ToMany([])})
            .validate(StandardNaming())
            .first
            .pointer,
        '/relationships');

    expect(
        Resource('articles', '2', relationships: {'type': ToMany([])})
            .validate(StandardNaming())
            .first
            .pointer,
        '/relationships');

    expect(
        Resource('articles', '2',
                relationships: {'foo': ToMany([])}, attributes: {'foo': 'bar'})
            .validate(StandardNaming())
            .first
            .pointer,
        '/fields');
  });
}
