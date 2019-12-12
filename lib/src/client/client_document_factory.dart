import 'package:json_api/document.dart';

/// This is a document factory used by [JsonApiClient]. It is responsible
/// for building the JSON representation of the outgoing resources.
class ClientDocumentFactory {
  /// Creates an instance of the factory.
  const ClientDocumentFactory({Api api = const Api(version: '1.0')})
      : _api = api;

  /// Makes a document containing a single resource.
  Document<ResourceData> makeResourceDocument(Resource resource) =>
      Document(ResourceData(_resourceObject(resource)), api: _api);

  /// Makes a document containing a to-many relationship.
  Document<ToMany> makeToManyDocument(Iterable<Identifier> ids) =>
      Document(ToMany(ids.map(IdentifierObject.fromIdentifier)), api: _api);

  /// Makes a document containing a to-one relationship.
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
  final Api _api;
}
