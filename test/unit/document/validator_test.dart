import 'package:json_api/json_api.dart';
import 'package:json_api/src/validation/_validation.dart';
import 'package:test/test.dart';

void main() {
  final validator = DocumentValidator();

  /// A resource object’s attributes and its relationships are collectively
  /// called its “fields”.
  ///
  /// Fields for a resource object MUST share a common namespace with each other
  /// and with type and id. In other words, a resource can not have an attribute
  /// and relationship with the same name, nor can it have an attribute
  /// or relationship named type or id.
  group('Resource Fields', () {
    final makeDoc = (ResourceObject r) => Document(ResourceData(r));

    test('Attribute: type', () {
      final errors = validator.errors(
          makeDoc(ResourceObject('apples', '1', attributes: {'type': '1'})));
      expect(errors.first.message, 'Invalid name "type"');
      expect(errors.first.path, '/data/attributes');
    });

    test('Attribute: id', () {
      final errors = validator.errors(
          makeDoc(ResourceObject('apples', '1', attributes: {'id': '1'})));
      expect(errors.first.message, 'Invalid name "id"');
      expect(errors.first.path, '/data/attributes');
    });

    test('Attributes: type, id', () {
      final errors = validator.errors(makeDoc(ResourceObject('apples', '1',
          attributes: {'id': '1', 'type': 'ddd'})));
      expect(errors.length, 2);
      expect(errors.first.message, 'Invalid name "type"');
      expect(errors.first.path, '/data/attributes');
      expect(errors.last.message, 'Invalid name "id"');
      expect(errors.last.path, '/data/attributes');
    });

    test('Relationships: type', () {
      final errors = validator.errors(makeDoc(
          ResourceObject('apples', '1', relationships: {'type': ToOne(null)})));
      expect(errors.first.message, 'Invalid name "type"');
      expect(errors.first.path, '/data/relationships');
    });

    test('Relationships: id', () {
      final errors = validator.errors(makeDoc(
          ResourceObject('apples', '1', relationships: {'id': ToOne(null)})));
      expect(errors.first.message, 'Invalid name "id"');
      expect(errors.first.path, '/data/relationships');
    });

    test('Relationships: type, id', () {
      final errors = validator.errors(makeDoc(ResourceObject('apples', '1',
          relationships: {'id': ToOne(null), 'type': ToOne(null)})));
      expect(errors.length, 2);
      expect(errors.first.message, 'Invalid name "type"');
      expect(errors.first.path, '/data/relationships');
      expect(errors.last.message, 'Invalid name "id"');
      expect(errors.last.path, '/data/relationships');
    });

    test('Relationships and Attributes', () {
      final errors = validator.errors(makeDoc(ResourceObject('apples', '1',
          relationships: {'foo': ToOne(null)}, attributes: {'foo': 2})));
      expect(errors.length, 1);
      expect(errors.first.message,
          'Name "foo" is used in both attributes and relationships');
      expect(errors.first.path, '/data');
    });
  });

  group('Member names', () {
    test('Error Document', () {
      final errors = validator.errors(Document.error([
        JsonApiError(meta: {'_foo': 2, 'bar': 1})
      ]));
      expect(errors.length, 1);
      expect(errors.first.message, 'Invalid member name "_foo"');
      expect(errors.first.path, '/errors/0/meta');
    });

    test('Empty Document', () {
      final errors = validator.errors(Document.empty({'_foo': 2, 'bar': 1}));
      expect(errors.length, 1);
      expect(errors.first.message, 'Invalid member name "_foo"');
      expect(errors.first.path, '/meta');
    });
  });
}
