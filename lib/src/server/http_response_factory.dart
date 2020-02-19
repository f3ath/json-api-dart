import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/query/page.dart';
import 'package:json_api/src/server/pagination.dart';

class HttpResponseFactory {
  /// A document containing a list of errors
  HttpResponse error(Iterable<ErrorObject> errors, int statusCode,
          Map<String, String> headers) =>
      _doc(Document.error(errors, api: _api),
          status: statusCode, headers: headers);

  /// A document containing a collection of resources
  HttpResponse collection(Iterable<Resource> collection,
      {int total,
      Iterable<Resource> included,
      Pagination pagination = const NoPagination()}) {
    return _doc(Document(
        ResourceCollectionData(collection.map(_resourceObject),
            links: {
              'self': Link(_self),
              ..._navigation(_self, total, pagination)
            },
            included: included?.map(_resourceObject)),
        api: _api));
  }

  HttpResponse accepted(Resource resource) =>
      _doc(
          Document(
              ResourceData(_resourceObject(resource),
                  links: {'self': Link(_self)}),
              api: _api),
          status: 202,
          headers: {
            'Content-Location':
                _routing.resource(resource.type, resource.id).toString()
          });

  /// A document containing just a meta member
  HttpResponse meta(Map<String, Object> meta) =>
      _doc(Document.empty(meta, api: _api));

  /// A document containing a single resource
  HttpResponse resource(Resource resource, {Iterable<Resource> included}) =>
      _doc(Document(
          ResourceData(_resourceObject(resource),
              links: {'self': Link(_self)},
              included: included?.map(_resourceObject)),
          api: _api));

  /// A document containing a single (primary) resource which has been created
  /// on the server. The difference with [resource] is that this
  /// method generates the `self` link to match the `location` header.
  ///
  /// This is the quote from the documentation:
  /// > If the resource object returned by the response contains a self key
  /// > in its links member and a Location header is provided, the value of
  /// > the self member MUST match the value of the Location header.
  ///
  /// See https://jsonapi.org/format/#crud-creating-responses-201
  HttpResponse resourceCreated(Resource resource) => _doc(
          Document(
              ResourceData(_resourceObject(resource), links: {
                'self': Link(_routing.resource(resource.type, resource.id))
              }),
              api: _api),
          status: 201,
          headers: {
            'Location': _routing.resource(resource.type, resource.id).toString()
          });

  HttpResponse seeOther(String type, String id) => HttpResponse(303,
      headers: {'Location': _routing.resource(type, id).toString()});

  /// A document containing a to-many relationship
  HttpResponse toMany(Iterable<Identifiers> identifiers, String type, String id,
          String relationship) =>
      _doc(Document(
          ToMany(
            identifiers.map(IdentifierObject.fromIdentifier),
            links: {
              'self': Link(_self),
              'related': Link(_routing.related(type, id, relationship))
            },
          ),
          api: _api));

  /// A document containing a to-one relationship
  HttpResponse toOneDocument(Identifiers identifier, String type, String id,
          String relationship) =>
      _doc(Document(
          ToOne(
            nullable(IdentifierObject.fromIdentifier)(identifier),
            links: {
              'self': Link(_self),
              'related': Link(_routing.related(type, id, relationship))
            },
          ),
          api: _api));

  HttpResponse noContent() => HttpResponse(204);

  HttpResponseFactory(this._routing, this._self);

  final Uri _self;
  final Routing _routing;
  final Api _api = Api(version: '1.0');

  HttpResponse _doc(Document d,
          {int status = 200, Map<String, String> headers = const {}}) =>
      HttpResponse(status,
          body: jsonEncode(d),
          headers: {...headers, 'Content-Type': Document.contentType});

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

  Map<String, Link> _navigation(Uri uri, int total, Pagination pagination) {
    final page = Page.fromUri(uri);

    return ({
      'first': pagination.first(),
      'last': pagination.last(total),
      'prev': pagination.prev(page),
      'next': pagination.next(page, total)
    }..removeWhere((k, v) => v == null))
        .map((k, v) => MapEntry(k, Link(v.addToUri(uri))));
  }
}
