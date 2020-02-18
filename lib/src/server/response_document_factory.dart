import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/query/page.dart';
import 'package:json_api/src/server/pagination.dart';

class ResponseDocumentFactory {
  /// A document containing a list of errors
  Document makeErrorDocument(Iterable<JsonApiError> errors) {
    return _document = Document.error(errors, api: _api);
  }

  /// A document containing a collection of resources
  Document makeCollectionDocument(Uri self, Iterable<Resource> collection,
      {int total, Iterable<Resource> included}) {
    return _document = Document(
        ResourceCollectionData(collection.map(_resourceObject),
            links: {'self': Link(self), ..._navigation(self, total)},
            included: included?.map(_resourceObject)),
        api: _api);
  }

  /// A document containing a single resource
  Document makeResourceDocument(Uri self, Resource resource,
      {Iterable<Resource> included}) {
    return _document = Document(
        ResourceData(_resourceObject(resource),
            links: {'self': Link(self)},
            included: included?.map(_resourceObject)),
        api: _api);
  }

  /// A document containing a single (primary) resource which has been created
  /// on the server. The difference with [makeResourceDocument] is that this
  /// method generates the `self` link to match the `location` header.
  ///
  /// This is the quote from the documentation:
  /// > If the resource object returned by the response contains a self key
  /// > in its links member and a Location header is provided, the value of
  /// > the self member MUST match the value of the Location header.
  ///
  /// See https://jsonapi.org/format/#crud-creating-responses-201
  Document makeCreatedResourceDocument(Resource resource) {
    return _document = makeResourceDocument(
        _urlFactory.resource(resource.type, resource.id), resource);
  }

  /// A document containing a to-many relationship
  Document makeToManyDocument(Uri self, Iterable<Identifiers> identifiers,
      String type, String id, String relationship) {
    return _document = Document(
        ToMany(
          identifiers.map(IdentifierObject.fromIdentifier),
          links: {
            'self': Link(self),
            'related': Link(_urlFactory.related(type, id, relationship))
          },
        ),
        api: _api);
  }

  /// A document containing a to-one relationship
  Document makeToOneDocument(Uri self, Identifiers identifier, String type,
      String id, String relationship) {
    return _document = Document(
        ToOne(
          nullable(IdentifierObject.fromIdentifier)(identifier),
          links: {
            'self': Link(self),
            'related': Link(_urlFactory.related(type, id, relationship))
          },
        ),
        api: _api);
  }

  /// A document containing just a meta member
  Document makeMetaDocument(Map<String, Object> meta) {
    return _document = Document.empty(meta, api: _api);
  }

  Document build() {
    return _document;
  }

  ResponseDocumentFactory(this._urlFactory, {Api api, Pagination pagination})
      : _api = api,
        _pagination = pagination ?? Pagination.none();

  final Routing _urlFactory;
  final Pagination _pagination;
  final Api _api;
  Document _document;

  ResourceObject _resourceObject(Resource r) =>
      ResourceObject(r.type, r.id, attributes: r.attributes, relationships: {
        ...r.toOne.map((k, v) => MapEntry(
            k,
            ToOne(
              nullable(IdentifierObject.fromIdentifier)(v),
              links: {
                'self': Link(_urlFactory.relationship(r.type, r.id, k)),
                'related': Link(_urlFactory.related(r.type, r.id, k))
              },
            ))),
        ...r.toMany.map((k, v) => MapEntry(
            k,
            ToMany(
              v.map(IdentifierObject.fromIdentifier),
              links: {
                'self': Link(_urlFactory.relationship(r.type, r.id, k)),
                'related': Link(_urlFactory.related(r.type, r.id, k))
              },
            )))
      }, links: {
        'self': Link(_urlFactory.resource(r.type, r.id))
      });

  Map<String, Link> _navigation(Uri uri, int total) {
    final page = Page.fromUri(uri);

    return ({
      'first': _pagination.first(),
      'last': _pagination.last(total),
      'prev': _pagination.prev(page),
      'next': _pagination.next(page, total)
    }..removeWhere((k, v) => v == null))
        .map((k, v) => MapEntry(k, Link(v.addToUri(uri))));
  }
}
