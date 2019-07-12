import 'package:json_api/document.dart';
import 'package:json_api/src/client/simple_document_builder.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/pagination/pagination.dart';
import 'package:json_api/src/query/page.dart';
import 'package:json_api/src/target.dart';
import 'package:json_api/url_design.dart';

/// The Document builder is used by the Client and the Server. It abstracts the process
/// of building response documents and is responsible for such aspects as
///  adding `meta` and `jsonapi` attributes and generating links
class DocumentBuilder implements SimpleDocumentBuilder {
  final UrlBuilder _urlBuilder;
  final Pagination _pagination;

  const DocumentBuilder(
      {UrlBuilder urlBuilder = const _NullObjectUrlDesign(),
      Pagination pagination = const _NoPagination()})
      : _pagination = pagination,
        _urlBuilder = urlBuilder;

  /// A document containing a list of errors
  Document errorDocument(Iterable<JsonApiError> errors) =>
      Document.error(errors);

  /// A collection of (primary) resources
  Document<ResourceCollectionData> collectionDocument(
          Iterable<Resource> collection,
          {Uri self,
          int total,
          Iterable<Resource> included}) =>
      Document(ResourceCollectionData(collection.map(_resourceObject),
          self: _link(self),
          navigation: _navigation(self, total),
          included: included?.map(_resourceObject)));

  /// A collection of related resources
  Document<ResourceCollectionData> relatedCollectionDocument(
          Iterable<Resource> collection,
          {Uri self,
          int total,
          Iterable<Resource> included}) =>
      Document(ResourceCollectionData(collection.map(_resourceObject),
          self: _link(self), navigation: _navigation(self, total)));

  /// A single (primary) resource
  Document<ResourceData> resourceDocument(Resource resource,
          {Uri self, Iterable<Resource> included}) =>
      Document(
        ResourceData(_resourceObject(resource),
            self: _link(self), included: included?.map(_resourceObject)),
      );

  /// A single related resource
  Document<ResourceData> relatedResourceDocument(Resource resource,
          {Uri self, Iterable<Resource> included}) =>
      Document(ResourceData(_resourceObject(resource),
          included: included?.map(_resourceObject), self: _link(self)));

  /// A to-many relationship
  Document<ToMany> toManyDocument(Iterable<Identifier> identifiers,
          {RelationshipTarget target, Uri self}) =>
      Document(ToMany(identifiers.map(_identifierObject),
          self: _link(self),
          related: target == null
              ? null
              : _link(_urlBuilder.related(
                  target.type, target.id, target.relationship))));

  /// A to-one relationship
  Document<ToOne> toOneDocument(Identifier identifier,
          {RelationshipTarget target, Uri self}) =>
      Document(ToOne(nullable(_identifierObject)(identifier),
          self: _link(self),
          related: target == null
              ? null
              : _link(_urlBuilder.related(
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
            self:
                _link(_urlBuilder.relationship(resource.type, resource.id, k)),
            related:
                _link(_urlBuilder.related(resource.type, resource.id, k))))));

    relationships.addAll(resource.toMany.map((k, v) => MapEntry(
        k,
        ToMany(v.map(_identifierObject),
            self:
                _link(_urlBuilder.relationship(resource.type, resource.id, k)),
            related:
                _link(_urlBuilder.related(resource.type, resource.id, k))))));

    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes,
        relationships: relationships,
        self: _link(_urlBuilder.resource(resource.type, resource.id)));
  }

  Navigation _navigation(Uri uri, int total) {
    if (uri == null) return Navigation();
    final page = Page.decode(uri.queryParametersAll);
    return Navigation(
      first: _link(_pagination.first()?.addTo(uri)),
      last: _link(_pagination.last(total)?.addTo(uri)),
      prev: _link(_pagination.prev(page)?.addTo(uri)),
      next: _link(_pagination.next(page, total)?.addTo(uri)),
    );
  }

  Link _link(Uri uri) => uri == null ? null : Link(uri);
}

class _NullObjectUrlDesign implements UrlBuilder {
  const _NullObjectUrlDesign();

  @override
  Uri collection(String type) => null;

  @override
  Uri related(String type, String id, String relationship) => null;

  @override
  Uri relationship(String type, String id, String relationship) => null;

  @override
  Uri resource(String type, String id) => null;
}

class _NoPagination implements Pagination {
  const _NoPagination();

  @override
  Page first() => null;

  @override
  Page last(int total) => null;

  @override
  int limit(Page page) => -1;

  @override
  Page next(Page page, [int total]) => null;

  @override
  int offset(Page page) => 0;

  @override
  Page prev(Page page) => null;
}
