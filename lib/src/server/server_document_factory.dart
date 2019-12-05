import 'package:json_api/document.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/pagination/no_pagination.dart';
import 'package:json_api/src/pagination/pagination.dart';
import 'package:json_api/src/query/page.dart';
import 'package:json_api/url_design.dart';

class ServerDocumentFactory {
  final UrlFactory _url;
  final Pagination _pagination;
  final Api _api;

  const ServerDocumentFactory(this._url,
      {Api api = const Api(version: '1.0'),
      Pagination pagination = const NoPagination()})
      : _api = api,
        _pagination = pagination;

  /// A document containing a list of errors
  Document makeErrorDocument(Iterable<JsonApiError> errors) =>
      Document.error(errors, api: _api);

  /// A document containing a collection of (primary) resources
  Document<ResourceCollectionData> makeCollectionDocument(
          Uri self, Iterable<Resource> collection,
          {int total, Iterable<Resource> included}) =>
      Document(
          ResourceCollectionData(collection.map(_resourceObject),
              self: Link(self),
              navigation: _navigation(self, total),
              included: included?.map(_resourceObject)),
          api: _api);

  /// A document containing a collection of related resources
  Document<ResourceCollectionData> makeRelatedCollectionDocument(
          Uri self, Iterable<Resource> collection,
          {int total, Iterable<Resource> included}) =>
      Document(
          ResourceCollectionData(collection.map(_resourceObject),
              self: Link(self), navigation: _navigation(self, total)),
          api: _api);

  /// A document containing a single (primary) resource
  Document<ResourceData> makeResourceDocument(Uri self, Resource resource,
          {Iterable<Resource> included}) =>
      Document(
          ResourceData(_resourceObject(resource),
              self: Link(self), included: included?.map(_resourceObject)),
          api: _api);

  /// A document containing a single related resource
  Document<ResourceData> makeRelatedResourceDocument(
          Uri self, Resource resource, {Iterable<Resource> included}) =>
      Document(
          ResourceData(_resourceObject(resource),
              included: included?.map(_resourceObject), self: Link(self)),
          api: _api);

  /// A document containing a to-many relationship
  Document<ToMany> makeToManyDocument(
          Uri self,
          Iterable<Identifier> identifiers,
          String type,
          String id,
          String relationship) =>
      Document(
          ToMany(
            identifiers.map(IdentifierObject.fromIdentifier),
            self: Link(self),
            related: Link(_url.related(type, id, relationship)),
          ),
          api: _api);

  /// A document containing a to-one relationship
  Document<ToOne> makeToOneDocument(Uri self, Identifier identifier,
          String type, String id, String relationship) =>
      Document(
          ToOne(
            nullable(IdentifierObject.fromIdentifier)(identifier),
            self: Link(self),
            related: Link(_url.related(type, id, relationship)),
          ),
          api: _api);

  /// A document containing just a meta member
  Document makeMetaDocument(Map<String, Object> meta) =>
      Document.empty(meta, api: _api);

  ResourceObject _resourceObject(Resource r) => ResourceObject(r.type, r.id,
      attributes: r.attributes,
      relationships: {
        ...r.toOne.map((k, v) => MapEntry(
            k,
            ToOne(
              IdentifierObject.fromIdentifier(v),
              self: Link(_url.relationship(r.type, r.id, k)),
              related: Link(_url.related(r.type, r.id, k)),
            ))),
        ...r.toMany.map((k, v) => MapEntry(
            k,
            ToMany(
              v.map(IdentifierObject.fromIdentifier),
              self: Link(_url.relationship(r.type, r.id, k)),
              related: Link(_url.related(r.type, r.id, k)),
            )))
      },
      self: Link(_url.resource(r.type, r.id)));

  Navigation _navigation(Uri uri, int total) {
    final page = Page.fromUri(uri);
    return Navigation(
      first: nullable(_link)(_pagination.first()?.addToUri(uri)),
      last: nullable(_link)(_pagination.last(total)?.addToUri(uri)),
      prev: nullable(_link)(_pagination.prev(page)?.addToUri(uri)),
      next: nullable(_link)(_pagination.next(page, total)?.addToUri(uri)),
    );
  }

  Link _link(Uri uri) => Link(uri);
}
