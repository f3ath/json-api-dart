import 'package:json_api/json_api.dart';
import 'package:json_api/src/nullable.dart';

class SimpleDocumentBuilder {
  const SimpleDocumentBuilder();

  Document<ResourceData> resourceDocument(Resource resource) {
    return Document(ResourceData(ResourceObject(
      resource.type,
      resource.id,
      attributes: resource.attributes,
      relationships: <String, Relationship>{
        ...resource.toOne.map((k, v) => MapEntry(k, _toOne(v))),
        ...resource.toMany.map((k, v) => MapEntry(k, _toMany(v)))
      },
    )));
  }

  Document<ToMany> toManyDocument(List<Identifier> identifiers) =>
      Document(_toMany(identifiers));

  Document<ToOne> toOneDocument(Identifier identifier) =>
      Document(_toOne(identifier));

  ToMany _toMany(List<Identifier> v) => ToMany(v.map(_identifier));

  ToOne _toOne(Identifier v) => ToOne(nullable(_identifier)(v));

  IdentifierObject _identifier(Identifier identifier) =>
      IdentifierObject(identifier.type, identifier.id);
}
