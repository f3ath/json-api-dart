import 'package:json_api/document.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/contracts/document_builder.dart';
import 'package:json_api/src/server/contracts/page.dart';
import 'package:json_api/src/server/contracts/router.dart';
import 'package:json_api/src/server/request_target.dart';

class StandardDocumentBuilder implements DocumentBuilder {
  final UriBuilder uriBuilder;

  StandardDocumentBuilder(this.uriBuilder);

  Document error(Iterable<JsonApiError> errors) => Document.error(errors);

  Document<ResourceCollectionData> collection(
          Collection<Resource> collection, CollectionTarget target, Uri self,
          {Iterable<Resource> included}) =>
      Document(ResourceCollectionData(collection.elements.map(_resourceObject),
          self: Link(self), pagination: _pagination(collection.page, target)));

  Document<ResourceCollectionData> relatedCollection(
          Collection<Resource> resources,
          RelatedResourceTarget target,
          Uri self,
          {Iterable<Resource> included}) =>
      Document(ResourceCollectionData(resources.elements.map(_resourceObject),
          self: Link(self), pagination: _pagination(resources.page, target)));

  Document<ResourceData> resource(
          Resource resource, ResourceTarget target, Uri self,
          {Iterable<Resource> included}) =>
      Document(
        ResourceData(_resourceObject(resource),
            self: Link(uriBuilder.resource(target.type, target.id)),
            included: included?.map(_resourceObject)),
      );

  Document<ResourceData> relatedResource(
          Resource resource, RelatedResourceTarget target, Uri self,
          {Iterable<Resource> included}) =>
      Document(
        ResourceData(_resourceObject(resource),
            included: included?.map(_resourceObject),
            self: Link(uriBuilder.relatedResource(
                target.type, target.id, target.relationship))),
      );

  Document<ToMany> toMany(Iterable<Identifier> collection,
          RelationshipTarget target, Uri self) =>
      Document(ToMany(collection.map(_identifierObject),
          self: Link(uriBuilder.relationship(
              target.type, target.id, target.relationship)),
          related: Link(uriBuilder.relatedResource(
              target.type, target.id, target.relationship))));

  Document<ToOne> toOne(
          Identifier identifier, RelationshipTarget target, Uri self) =>
      Document(ToOne(nullable(_identifierObject)(identifier),
          self: Link(uriBuilder.relationship(
              target.type, target.id, target.relationship)),
          related: Link(uriBuilder.relatedResource(
              target.type, target.id, target.relationship))));

  Document meta(Map<String, Object> meta) => Document.empty(meta);

  IdentifierObject _identifierObject(Identifier id) =>
      IdentifierObject(id.type, id.id);

  ResourceObject _resourceObject(Resource resource) {
    final relationships = <String, Relationship>{};
    relationships.addAll(resource.toOne.map((k, v) => MapEntry(
        k,
        ToOne(nullable(_identifierObject)(v),
            self: Link(uriBuilder.relationship(resource.type, resource.id, k)),
            related: Link(
                uriBuilder.relatedResource(resource.type, resource.id, k))))));
    relationships.addAll(resource.toMany.map((k, v) => MapEntry(
        k,
        ToMany(v.map(_identifierObject),
            self: Link(uriBuilder.relationship(resource.type, resource.id, k)),
            related: Link(
                uriBuilder.relatedResource(resource.type, resource.id, k))))));

    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes,
        relationships: relationships,
        self: Link(uriBuilder.resource(resource.type, resource.id)));
  }

  Pagination _pagination(Page page, RequestTarget target) {
    return page == null
        ? Pagination.empty()
        : Pagination.fromLinks(page.map((_) => Link(
            target.uri(uriBuilder).replace(queryParameters: _.parameters))));
  }
}
