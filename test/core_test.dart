import 'package:json_api/core.dart';
import 'package:test/test.dart';

void main() {
  group('Identifier', () {
    test('must have type and id', () {
      final id = Identifier('apples', '1');
      expect(id.type, 'apples');
      expect(id.id, '1');
    });
    test('type can not be null', () {
      expect(() => Identifier(null, '1'), throwsArgumentError);
    });
    test('id can not be null', () {
      expect(() => Identifier('apples', null), throwsArgumentError);
    });
    test('identifies the resource', () {
      final apple1 = Resource('apples', '1');
      final apple2 = Resource('apples', '2');
      final pear1 = Resource('pears', '1');
      expect(Identifier.of(apple1).identifies(apple1), true);
      expect(Identifier.of(apple2).identifies(apple1), false);
      expect(Identifier.of(pear1).identifies(apple1), false);
    });
  });

  group('Resource', () {
    test('must have type and id, attributes, toOne, toMany', () {
      final r = Resource('articles', '1', attributes: {
        'title': 'Yo!'
      }, toOne: {
        'author': Identifier('people', '2')
      }, toMany: {
        'comments': [Identifier('messages', '4'), Identifier('messages', '5')]
      });
      expect(r.type, 'articles');
      expect(r.id, '1');
      expect(r.attributes['title'], 'Yo!');
      expect(r.toOne['author'].type, 'people');
      expect(r.toMany['comments'].first.type, 'messages');
    });
    test('type can not be null', () {
      expect(() => Resource(null, '1'), throwsArgumentError);
    });
    test('id can be null', () {
      expect(Resource('apples', null).id, isNull);
    });
    test('can not have attributes or relationships named "type" or "id" ', () {
      expect(() => Resource('articles', '1', attributes: {'type': 'foo'}),
          throwsArgumentError);
      expect(() => Resource('articles', '1', toMany: {'id': []}),
          throwsArgumentError);
    });
    test('can not have attributes or relationships with the same name', () {
      expect(
          () => Resource('articles', '1',
              attributes: {'foo': 'bar'}, toMany: {'foo': []}),
          throwsArgumentError);
    });
  });
}
