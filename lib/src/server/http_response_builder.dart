import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/query/page.dart';
import 'package:json_api/src/server/pagination.dart';

class HttpResponseBuilder {
  /// A document containing a list of errors
  void errorDocument(Iterable<JsonApiError> errors) {
    _headers['Content-Type'] = Document.contentType;
    _document = Document.error(errors, api: _api);
  }

  /// A document containing a collection of resources
  void collectionDocument(Iterable<Resource> collection,
      {int total, Iterable<Resource> included}) {
    _headers['Content-Type'] = Document.contentType;

    _document = Document(
        ResourceCollectionData(collection.map(_resourceObject),
            links: {'self': Link(_self), ..._navigation(_self, total)},
            included: included?.map(_resourceObject)),
        api: _api);
  }

  /// A document containing a single resource
  void resourceDocument(Resource resource, {Iterable<Resource> included}) {
    _headers['Content-Type'] = Document.contentType;

    _document = Document(
        ResourceData(_resourceObject(resource),
            links: {'self': Link(_self)},
            included: included?.map(_resourceObject)),
        api: _api);
  }

  /// A document containing a single (primary) resource which has been created
  /// on the server. The difference with [resourceDocument] is that this
  /// method generates the `self` link to match the `location` header.
  ///
  /// This is the quote from the documentation:
  /// > If the resource object returned by the response contains a self key
  /// > in its links member and a Location header is provided, the value of
  /// > the self member MUST match the value of the Location header.
  ///
  /// See https://jsonapi.org/format/#crud-creating-responses-201
  void createdResourceDocument(Resource resource) {
    _headers['Content-Type'] = Document.contentType;

    _document = Document(
        ResourceData(_resourceObject(resource), links: {
          'self': Link(_routing.resource(resource.type, resource.id))
        }),
        api: _api);
  }

  /// A document containing a to-many relationship
  void toManyDocument(Iterable<Identifiers> identifiers, String type, String id,
      String relationship) {
    _headers['Content-Type'] = Document.contentType;

    _document = Document(
        ToMany(
          identifiers.map(IdentifierObject.fromIdentifier),
          links: {
            'self': Link(_self),
            'related': Link(_routing.related(type, id, relationship))
          },
        ),
        api: _api);
  }

  /// A document containing a to-one relationship
  void toOneDocument(
      Identifiers identifier, String type, String id, String relationship) {
    _headers['Content-Type'] = Document.contentType;

    _document = Document(
        ToOne(
          nullable(IdentifierObject.fromIdentifier)(identifier),
          links: {
            'self': Link(_self),
            'related': Link(_routing.related(type, id, relationship))
          },
        ),
        api: _api);
  }

  /// A document containing just a meta member
  void metaDocument(Map<String, Object> meta) {
    _headers['Content-Type'] = Document.contentType;

    _document = Document.empty(meta, api: _api);
  }

  void addContentLocation(String type, String id) {
    _headers['Content-Location'] = _routing.resource(type, id).toString();
  }

  void addLocation(String type, String id) {
    _headers['Location'] = _routing.resource(type, id).toString();
  }

  HttpResponse buildHttpResponse() {
    return HttpResponse(statusCode,
        body: _document == null ? null : jsonEncode(_document),
        headers: _headers);
  }

  void addHeaders(Map<String, String> headers) {
    _headers.addAll(headers);
  }

  HttpResponseBuilder(this._routing, this._self);

  final Uri _self;
  final Routing _routing;
  final Pagination _pagination = Pagination.none();
  final Api _api = Api(version: '1.0');
  Document _document;
  int statusCode = 200;
  final _headers = <String, String>{};

  ResourceObject _resourceObject(Resource r) =>
      ResourceObject(r.type, r.id, attributes: r.attributes, relationships: {
        ...r.toOne.map((k, v) => MapEntry(
            k,
            ToOne(
              nullable(IdentifierObject.fromIdentifier)(v),
              links: {
                'self': Link(_routing.relationship(r.type, r.id, k)),
                'related': Link(_routing.related(r.type, r.id, k))
              },
            ))),
        ...r.toMany.map((k, v) => MapEntry(
            k,
            ToMany(
              v.map(IdentifierObject.fromIdentifier),
              links: {
                'self': Link(_routing.relationship(r.type, r.id, k)),
                'related': Link(_routing.related(r.type, r.id, k))
              },
            )))
      }, links: {
        'self': Link(_routing.resource(r.type, r.id))
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
