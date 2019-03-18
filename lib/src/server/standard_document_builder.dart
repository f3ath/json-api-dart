import 'package:json_api/document.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/contracts/document_builder.dart';
import 'package:json_api/src/server/contracts/page.dart';
import 'package:json_api/src/server/contracts/router.dart';

class StandardDocumentBuilder implements DocumentBuilder {
  final UriBuilder uriBuilder;

  StandardDocumentBuilder(this.uriBuilder);

  Document error(Iterable<JsonApiError> errors) => Document.error(errors);

  Document<ResourceCollectionData> collection(
      Iterable<Resource> resource, String type, Uri self,
      {Page page, Iterable<Resource> included}) {
    return Document(ResourceCollectionData(resource.map(_resourceObject),
        self: Link(self),
        pagination: page == null
            ? Pagination.empty()
            : Pagination.fromLinks(page.map((_) =>
                Link(uriBuilder.collection(type, parameters: _.parameters))))));
  }

  Document<ResourceCollectionData> relatedCollection(
      Iterable<Resource> resource,
      String type,
      String id,
      String relationship,
      Uri self,
      {Page page,
      Iterable<Resource> included}) {
    final pagination = _pagination(page, type, id, relationship);
    return Document(ResourceCollectionData(resource.map(_resourceObject),
        self: Link(self), pagination: pagination));
  }

  Document<ResourceData> resource(
      Resource resource, String type, String id, Uri self,
      {Iterable<Resource> included}) {
    return Document(
      ResourceData(_resourceObject(resource),
          self: Link(uriBuilder.resource(type, id)),
          included: included?.map(_resourceObject)),
    );
  }

  Document<ResourceData> relatedResource(
      Resource resource, String type, String id, String relationship, Uri self,
      {Iterable<Resource> included}) {
    return Document(
      ResourceData(_resourceObject(resource),
          included: included?.map(_resourceObject),
          self: Link(uriBuilder.related(type, id, relationship))),
    );
  }

  Document<ToMany> toMany(Iterable<Identifier> collection, String type,
      String id, String relationship, Uri self) {
    return Document(ToMany(collection.map(_rdentifierObject),
        self: Link(uriBuilder.relationship(type, id, relationship)),
        related: Link(uriBuilder.related(type, id, relationship))));
  }

  Document<ToOne> toOne(Identifier identifier, String type, String id,
      String relationship, Uri self) {
    return Document(ToOne(nullable(_rdentifierObject)(identifier),
        self: Link(uriBuilder.relationship(type, id, relationship)),
        related: Link(uriBuilder.related(type, id, relationship))));
  }

  Document meta(Map<String, Object> meta) => Document.empty(meta);

  IdentifierObject _rdentifierObject(Identifier id) =>
      IdentifierObject(id.type, id.id);

  ResourceObject _resourceObject(Resource resource) {
    final relationships = <String, Relationship>{};
    relationships.addAll(resource.toOne.map((k, v) => MapEntry(
        k,
        ToOne(nullable(_rdentifierObject)(v),
            self: Link(uriBuilder.relationship(resource.type, resource.id, k)),
            related:
                Link(uriBuilder.related(resource.type, resource.id, k))))));
    relationships.addAll(resource.toMany.map((k, v) => MapEntry(
        k,
        ToMany(v.map(_rdentifierObject),
            self: Link(uriBuilder.relationship(resource.type, resource.id, k)),
            related:
                Link(uriBuilder.related(resource.type, resource.id, k))))));

    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes,
        relationships: relationships,
        self: Link(uriBuilder.resource(resource.type, resource.id)));
  }

  Pagination _pagination(
      Page page, String type, String id, String relationship) {
    return page == null
        ? Pagination.empty()
        : Pagination.fromLinks(page.map((_) => Link(uriBuilder
            .related(type, id, relationship, parameters: _.parameters))));
  }
}
