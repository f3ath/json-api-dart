import 'package:json_api/document.dart';
import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/json_api_error.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_collection_data.dart';
import 'package:json_api/src/document/resource_data.dart';
import 'package:json_api/src/document/resource_object.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/routing.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/pagination/pagination_strategy.dart';
import 'package:json_api/src/server/request/page.dart';
import 'package:json_api/src/server/request/request.dart';

/// The Document builder is used by JsonApiServer. It abstracts the process
/// of building response documents and is responsible for such aspects as
///  adding `meta` and `jsonapi` attributes and generating links
class ServerDocumentBuilder {
  final Routing _urlDesign;
  final PaginationStrategy _paginationStrategy;

  const ServerDocumentBuilder(this._urlDesign, this._paginationStrategy);

  /// A document containing a list of errors
  Document errorDocument(Iterable<JsonApiError> errors) =>
      Document.error(errors);

  /// A collection of (primary) resources
  Document<ResourceCollectionData> collectionDocument(
          Collection<Resource> collection, Uri self,
          {Iterable<Resource> included}) =>
      Document(ResourceCollectionData(collection.elements.map(_resourceObject),
          self: _link(self),
          pagination: _paginationLinks(self, collection.total)));

  /// A collection of related resources
  Document<ResourceCollectionData> relatedCollectionDocument(
          Collection<Resource> collection, Uri self,
          {Iterable<Resource> included}) =>
      Document(ResourceCollectionData(collection.elements.map(_resourceObject),
          self: _link(self),
          pagination: _paginationLinks(self, collection.total)));

  /// A single (primary) resource
  Document<ResourceData> resourceDocument(Resource resource, Uri self,
          {Iterable<Resource> included}) =>
      Document(
        ResourceData(_resourceObject(resource),
            self: _link(self), included: included?.map(_resourceObject)),
      );

  /// A single related resource
  Document<ResourceData> relatedResourceDocument(Resource resource, Uri self,
          {Iterable<Resource> included}) =>
      Document(ResourceData(_resourceObject(resource),
          included: included?.map(_resourceObject), self: _link(self)));

  /// A to-many relationship
  Document<ToMany> toManyDocument(Iterable<Identifier> identifiers,
          RelationshipTarget target, Uri self) =>
      Document(ToMany(identifiers.map(_identifierObject),
          self: _link(self),
          related: _link(_urlDesign.related(
              target.type, target.id, target.relationship))));

  /// A to-one relationship
  Document<ToOne> toOneDocument(
          Identifier identifier, RelationshipTarget target, Uri self) =>
      Document(ToOne(nullable(_identifierObject)(identifier),
          self: _link(self),
          related: _link(_urlDesign.related(
              target.type, target.id, target.relationship))));

  /// A document containing just a meta member
  Document metaDocument(Map<String, Object> meta) => Document.empty(meta);

  IdentifierObject _identifierObject(Identifier id) =>
      IdentifierObject(id.type, id.id);

  ResourceObject _resourceObject(Resource resource) {
    final relationships = <String, Relationship>{};
    relationships.addAll(resource.toOne.map((k, v) => MapEntry(
        k,
        ToOne(nullable(_identifierObject)(v),
            self: _link(_urlDesign.relationship(resource.type, resource.id, k)),
            related:
                _link(_urlDesign.related(resource.type, resource.id, k))))));

    relationships.addAll(resource.toMany.map((k, v) => MapEntry(
        k,
        ToMany(v.map(_identifierObject),
            self: _link(_urlDesign.relationship(resource.type, resource.id, k)),
            related:
                _link(_urlDesign.related(resource.type, resource.id, k))))));

    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes,
        relationships: relationships,
        self: _link(_urlDesign.resource(resource.type, resource.id)));
  }

  Pagination _paginationLinks(Uri uri, int total) {
    final page = Page.decode(uri.queryParametersAll);
    return Pagination(
      first: _link(_paginationStrategy.first().addTo(uri)),
      last: _link(_paginationStrategy.last(total)?.addTo(uri)),
      prev: _link(_paginationStrategy.prev(page)?.addTo(uri)),
      next: _link(_paginationStrategy.next(page, total)?.addTo(uri)),
    );
  }

  Link _link(Uri uri) => uri == null ? null : Link(uri);
}
