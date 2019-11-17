import 'package:json_api/document.dart';
import 'package:json_api/src/client/client_document_factory.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/pagination/no_pagination.dart';
import 'package:json_api/src/pagination/pagination.dart';
import 'package:json_api/src/query/page.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/src/target.dart';
import 'package:json_api/url_design.dart';

/// The Document factory is used by the Client and the Server. It abstracts the process
/// of creating response documents and is responsible for such aspects as
///  adding `meta` and `jsonapi` attributes, and generating links
class DocumentFactory implements ClientDocumentFactory, ServerDocumentFactory {
  final UrlFactory _url;
  final Pagination _pagination;
  final Api _api;

  const DocumentFactory(
      {UrlFactory urlBuilder = const _NullObjectUrlDesign(),
      Pagination pagination = const NoPagination(),
      Api api})
      : _pagination = pagination,
        _url = urlBuilder,
        _api = api;

  /// A document containing a list of errors
  Document makeErrorDocument(Iterable<JsonApiError> errors) =>
      Document.error(errors, api: _api);

  /// A document containing a collection of (primary) resources
  Document<ResourceCollectionData> makeCollectionDocument(
          Iterable<Resource> collection,
          {Uri self,
          int total,
          Iterable<Resource> included}) =>
      Document(
          ResourceCollectionData(collection.map(_resourceObject),
              self: _link(self),
              navigation: _navigation(self, total),
              included: included?.map(_resourceObject)),
          api: _api);

  /// A document containing a collection of related resources
  Document<ResourceCollectionData> makeRelatedCollectionDocument(
          Iterable<Resource> collection,
          {Uri self,
          int total,
          Iterable<Resource> included}) =>
      Document(
          ResourceCollectionData(collection.map(_resourceObject),
              self: _link(self), navigation: _navigation(self, total)),
          api: _api);

  /// A document containing a single (primary) resource
  Document<ResourceData> makeResourceDocument(Resource resource,
          {Uri self, Iterable<Resource> included}) =>
      Document(
          ResourceData(_resourceObject(resource),
              self: _link(self), included: included?.map(_resourceObject)),
          api: _api);

  /// A document containing a single related resource
  Document<ResourceData> makeRelatedResourceDocument(Resource resource,
          {Uri self, Iterable<Resource> included}) =>
      Document(
          ResourceData(_resourceObject(resource),
              included: included?.map(_resourceObject), self: _link(self)),
          api: _api);

  /// A document containing a to-many relationship
  Document<ToMany> makeToManyDocument(Iterable<Identifier> identifiers,
          {RelationshipTarget target, Uri self}) =>
      Document(
          ToMany(identifiers.map(_identifierObject),
              self: _link(self), related: _relatedLinkOrNull(target)),
          api: _api);

  /// A document containing a to-one relationship
  Document<ToOne> makeToOneDocument(Identifier identifier,
          {RelationshipTarget target, Uri self}) =>
      Document(
          ToOne(nullable(_identifierObject)(identifier),
              self: _link(self), related: _relatedLinkOrNull(target)),
          api: _api);

  /// A document containing just a meta member
  Document makeMetaDocument(Map<String, Object> meta) =>
      Document.empty(meta, api: _api);

  IdentifierObject _identifierObject(Identifier id) =>
      IdentifierObject(id.type, id.id);

  ResourceObject _resourceObject(Resource resource) {
    final relationships = <String, Relationship>{};
    relationships.addAll(resource.toOne.map((k, v) => MapEntry(
        k,
        ToOne(nullable(_identifierObject)(v),
            self: _link(_url.relationship(resource.type, resource.id, k)),
            related: _link(_url.related(resource.type, resource.id, k))))));

    relationships.addAll(resource.toMany.map((k, v) => MapEntry(
        k,
        ToMany(v.map(_identifierObject),
            self: _link(_url.relationship(resource.type, resource.id, k)),
            related: _link(_url.related(resource.type, resource.id, k))))));

    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes,
        relationships: relationships,
        self: _link(_url.resource(resource.type, resource.id)));
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

  Link _relatedLinkOrNull(RelationshipTarget target) {
    return target == null
        ? null
        : _link(_url.related(target.type, target.id, target.relationship));
  }

  Link _link(Uri uri) => uri == null ? null : Link(uri);
}

class _NullObjectUrlDesign implements UrlFactory {
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
