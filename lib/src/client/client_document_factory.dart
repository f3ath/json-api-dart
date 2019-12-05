import 'package:json_api/document.dart';

class ClientDocumentFactory {
  final Api _api;

  const ClientDocumentFactory({Api api = const Api(version: '1.0')})
      : _api = api;

  Document<ResourceData> makeResourceDocument(Resource resource) =>
      Document(ResourceData(_resourceObject(resource)), api: _api);

  /// A document containing a to-many relationship
  Document<ToMany> makeToManyDocument(Iterable<Identifier> ids) =>
      Document(ToMany(ids.map(IdentifierObject.fromIdentifier)), api: _api);

  /// A document containing a to-one relationship
  Document<ToOne> makeToOneDocument(Identifier id) =>
      Document(ToOne(IdentifierObject.fromIdentifier(id)), api: _api);

  ResourceObject _resourceObject(Resource resource) =>
      ResourceObject(resource.type, resource.id,
          attributes: resource.attributes,
          relationships: {
            ...resource.toOne.map((k, v) =>
                MapEntry(k, ToOne(IdentifierObject.fromIdentifier(v)))),
            ...resource.toMany.map((k, v) =>
                MapEntry(k, ToMany(v.map(IdentifierObject.fromIdentifier))))
          });
}
