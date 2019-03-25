import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/document_builder.dart';
import 'package:json_api/src/server/page.dart';
import 'package:json_api/src/server/request_target.dart';
import 'package:json_api/src/server/router.dart';
import 'package:json_api_document/document.dart';

class StandardDocumentBuilder implements DocumentBuilder {
  final URLDesign design;

  StandardDocumentBuilder(this.design);

  Document error(Iterable<JsonApiError> errors) => Document.error(errors);

  Document<ResourceCollectionData> collection(
          Collection<Resource> collection, CollectionTarget target, Uri self,
          {Iterable<Resource> included}) =>
      Document(ResourceCollectionData(collection.elements.map(_resourceObject),
          self: Link(self),
          pagination: _pagination(collection.page, self, target)));

  Document<ResourceCollectionData> relatedCollection(
          Collection<Resource> resources, RelatedTarget target, Uri self,
          {Iterable<Resource> included}) =>
      Document(ResourceCollectionData(resources.elements.map(_resourceObject),
          self: Link(self),
          pagination: _pagination(resources.page, self, target)));

  Document<ResourceData> resource(
          Resource resource, ResourceTarget target, Uri self,
          {Iterable<Resource> included}) =>
      Document(
        ResourceData(_resourceObject(resource),
            self: Link(target.url(design)),
            included: included?.map(_resourceObject)),
      );

  Document<ResourceData> relatedResource(
          Resource resource, RelatedTarget target, Uri self,
          {Iterable<Resource> included}) =>
      Document(
        ResourceData(_resourceObject(resource),
            included: included?.map(_resourceObject),
            self: Link(target.url(design))),
      );

  Document<ToMany> toMany(Iterable<Identifier> collection,
          RelationshipTarget target, Uri self) =>
      Document(ToMany(collection.map(_identifierObject),
          self: Link(target.url(design)),
          related: Link(target.toRelated().url(design))));

  Document<ToOne> toOne(
          Identifier identifier, RelationshipTarget target, Uri self) =>
      Document(ToOne(nullable(_identifierObject)(identifier),
          self: Link(target.url(design)),
          related: Link(target.toRelated().url(design))));

  Document meta(Map<String, Object> meta) => Document.empty(meta);

  IdentifierObject _identifierObject(Identifier id) =>
      IdentifierObject(id.type, id.id);

  ResourceObject _resourceObject(Resource resource) {
    final relationships = <String, Relationship>{};
    relationships.addAll(resource.toOne.map((k, v) => MapEntry(
        k,
        ToOne(nullable(_identifierObject)(v),
            self: Link(
                RelationshipTarget(resource.type, resource.id, k).url(design)),
            related: Link(
                RelatedTarget(resource.type, resource.id, k).url(design))))));
    relationships.addAll(resource.toMany.map((k, v) => MapEntry(
        k,
        ToMany(v.map(_identifierObject),
            self: Link(
                RelationshipTarget(resource.type, resource.id, k).url(design)),
            related: Link(
                RelatedTarget(resource.type, resource.id, k).url(design))))));

    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes,
        relationships: relationships,
        self: Link(ResourceTarget(resource.type, resource.id).url(design)));
  }

  Pagination _pagination(Page page, Uri self, RequestTarget target) {
    if (page == null) return Pagination.empty();
    return Pagination.fromLinks(page.map((_) => Link(_.addTo(self))));
  }
}
