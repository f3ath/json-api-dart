import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/links/links_factory.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:json_api/src/server/relationship_target.dart';
import 'package:json_api/src/server/resource_target.dart';

/// The factory producing JSON:API Documents
class DocumentFactory {
  DocumentFactory({LinksFactory links = const NoLinks()}) : _links = links;

  final Api _api = Api(version: '1.0');

  final LinksFactory _links;

  /// An error document
  Document error(Iterable<ErrorObject> errors) =>
      Document.error(errors, api: _api);

  /// A resource collection document
  Document<ResourceCollectionData> collection(Iterable<Resource> collection,
          {int total,
          Iterable<Resource> included,
          Pagination pagination = const NoPagination()}) =>
      Document(
          ResourceCollectionData(collection.map(_resourceObject).toList(),
              links: _links.collection(total, pagination),
              included: included?.map(_resourceObject)),
          api: _api);

  /// An empty (meta) document
  Document empty(Map<String, Object> meta) => Document.empty(meta, api: _api);

  Document<ResourceData> resource(Resource resource,
          {Iterable<Resource> included}) =>
      Document(
          ResourceData(_resourceObject(resource),
              links: _links.resource(resource.type, resource.id),
              included: included?.map(_resourceObject)),
          api: _api);

  Document<ResourceData> resourceCreated(Resource resource) => Document(
      ResourceData(_resourceObject(resource),
          links: _links
              .createdResource(ResourceTarget(resource.type, resource.id))),
      api: _api);

  Document<ToMany> toMany(
          RelationshipTarget target, Iterable<Identifier> identifiers,
          {Iterable<Resource> included}) =>
      Document(
          ToMany(
            identifiers.map(IdentifierObject.fromIdentifier),
            links: _links.relationship(target),
          ),
          api: _api);

  Document<ToOne> toOne(RelationshipTarget target, Identifier identifier,
          {Iterable<Resource> included}) =>
      Document(
          ToOne(
            nullable(IdentifierObject.fromIdentifier)(identifier),
            links: _links.relationship(target),
          ),
          api: _api);

  ResourceObject _resourceObject(Resource r) => ResourceObject(r.type, r.id,
      attributes: r.attributes,
      relationships: {
        ...r.toOne.map((k, v) => MapEntry(
            k,
            ToOne(nullable(IdentifierObject.fromIdentifier)(v),
                links: _links.resourceRelationship(
                    RelationshipTarget(r.type, r.id, k))))),
        ...r.toMany.map((k, v) => MapEntry(
            k,
            ToMany(v.map(IdentifierObject.fromIdentifier),
                links: _links.resourceRelationship(
                    RelationshipTarget(r.type, r.id, k)))))
      },
      links: _links.createdResource(ResourceTarget(r.type, r.id)));
}
