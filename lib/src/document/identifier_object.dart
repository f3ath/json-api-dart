import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';

class IdentifierObject extends ResourceLinkage {
  final String type;
  final String id;
  final Map<String, Link> links = {};

  IdentifierObject(this.type, this.id);

  static IdentifierObject fromData(Object data) {
    if (data == null) return EmptyIdentifierObject();
    if (data is Map) {
      return IdentifierObject(data['type'], data['id']);
    }
    throw 'Can not parse IdentifierObject from $data';
  }

  toJson() => {'type': type, 'id': id};

  Identifier toIdentifier() => Identifier(type, id);

  static IdentifierObject fromIdentifier(Identifier id) =>
      id == null ? EmptyIdentifierObject() : IdentifierObject(id.type, id.id);
}

class EmptyIdentifierObject extends IdentifierObject {
  EmptyIdentifierObject() : super(null, null);

  toJson() => null;

  Identifier toIdentifier() => null;
}
