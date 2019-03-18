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

  Document<ResourceCollectionData> collection(Iterable<Resource> resource,
      String type, Uri self,
      {Page page, Iterable<Resource> included}) =>
      Document(ResourceCollectionData(resource.map(
          _resourceJson),
          self: Link(self),
          pagination: page == null
              ? Pagination.empty()
              : Pagination.fromLinks(page.map((_) =>
              Link(
                  uriBuilder.collection(type, parameters: _.parameters))))));

  Document<ResourceCollectionData> relatedCollection(
      Iterable<Resource> resource, String type,
      String id, String relationship, Uri self,
      {Page page, Iterable<Resource> included}) =>
      Document(ResourceCollectionData(resource.map(_resourceJson),
          self: Link(self),
          pagination: page == null
              ? Pagination.empty()
              : Pagination.fromLinks(page.map((_) =>
              Link(
                  uriBuilder.related(
                      type, id, relationship, parameters: _.parameters))))));

  Document<ResourceData> resource(Resource resource, String type, String id,
      Uri self,
      {Iterable<Resource> included}) =>
      Document(
        ResourceData(_resourceJson(resource),
            self: Link(uriBuilder.resource(type, id)),
            included: included?.map(_resourceJson)),
      );

  Document<ResourceData> relatedResource(Resource resource, String type,
      String id,
      String relationship, Uri self,
      {Iterable<Resource> included}) =>
      Document(
        ResourceData(
            _resourceJson(resource), included: included?.map(_resourceJson),
            self: Link(uriBuilder.related(type, id, relationship))),
      );

  Document<ToMany> toMany(Iterable<Identifier> collection, String type,
      String id,
      String relationship, Uri self) =>
      Document(ToMany(
          collection.map(_identifierJson),
          self: Link(uriBuilder.relationship(type, id, relationship)),
          related: Link(uriBuilder.related(type, id, relationship))));

  Document<ToOne> toOne(Identifier identifier, String type, String id,
      String relationship, Uri self) =>
      Document(ToOne(
          nullable(_identifierJson)(identifier),
          self: Link(uriBuilder.relationship(type, id, relationship)),
          related: Link(uriBuilder.related(type, id, relationship))));

  Document meta(Map<String, Object> meta) => Document.empty(meta);

  IdentifierJson _identifierJson(Identifier id) =>
      IdentifierJson(id.type, id.id);

  ResourceJson _resourceJson(Resource resource) {
    final relationships =
    <String, Relationship>{};
    relationships.addAll(resource.toOne.map((k, v) =>
        MapEntry(
            k, ToOne(nullable(_identifierJson)(v), self: Link(
            uriBuilder.relationship(resource.type, resource.id, k)),
            related: Link(
                uriBuilder.related(resource.type, resource.id, k))))));
    relationships.addAll(
        resource.toMany.map(
                (k, v) =>
                MapEntry(
                    k, ToMany(v.map(_identifierJson), self: Link(
                    uriBuilder.relationship(resource.type, resource.id, k)),
                    related: Link(
                        uriBuilder.related(resource.type, resource.id, k))))));

    return ResourceJson(resource.type, resource.id,
        attributes: resource.attributes,
        relationships: relationships,
        self: Link(uriBuilder.resource(resource.type, resource.id)));
  }
}
