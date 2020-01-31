import 'package:json_api/document.dart';
import 'package:json_api/src/nullable.dart';

/// The document factory used by the client. It is responsible
/// for building the JSON representation of the outgoing resources.
class RequestDocumentFactory {
  /// Makes a document containing a single resource.
  Document<ResourceData> resourceDocument(Resource resource) =>
      Document(ResourceData(_resourceObject(resource)), api: _api);

  /// Makes a document containing a to-many relationship.
  Document<ToMany> toManyDocument(Iterable<Identifier> ids) =>
      Document(ToMany(ids.map(IdentifierObject.fromIdentifier)), api: _api);

  /// Makes a document containing a to-one relationship.
  Document<ToOne> toOneDocument(Identifier id) =>
      Document(ToOne(nullable(IdentifierObject.fromIdentifier)(id)), api: _api);

  /// Creates an instance of the factory.
  RequestDocumentFactory({Api api}) : _api = api ?? Api(version: '1.0');

  final Api _api;

  ResourceObject _resourceObject(Resource resource) =>
      ResourceObject(resource.type, resource.id,
          attributes: resource.attributes,
          relationships: {
            ...resource.toOne.map((k, v) => MapEntry(
                k, ToOne(nullable(IdentifierObject.fromIdentifier)(v)))),
            ...resource.toMany.map((k, v) =>
                MapEntry(k, ToMany(v.map(IdentifierObject.fromIdentifier))))
          });
}
