import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/query/page.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:json_api/src/server/response_converter.dart';

/// An implementation of [ResponseConverter] converting to [HttpResponse].
class HttpResponseFactory implements ResponseConverter<HttpResponse> {
  @override
  HttpResponse error(Iterable<ErrorObject> errors, int statusCode,
          Map<String, String> headers) =>
      _document(Document.error(errors, api: _api),
          status: statusCode, headers: headers);

  @override
  HttpResponse collection(Iterable<Resource> collection,
      {int total,
      Iterable<Resource> included,
      Pagination pagination = const NoPagination()}) {
    return _document(Document(
        ResourceCollectionData(collection.map(_resourceObject),
            links: {
              'self': Link(_self),
              ..._navigation(_self, total, pagination)
            },
            included: included?.map(_resourceObject)),
        api: _api));
  }

  @override
  HttpResponse accepted(Resource resource) =>
      _document(
          Document(
              ResourceData(_resourceObject(resource),
                  links: {'self': Link(_self)}),
              api: _api),
          status: 202,
          headers: {
            'Content-Location':
                _routing.resource(resource.type, resource.id).toString()
          });

  @override
  HttpResponse meta(Map<String, Object> meta) =>
      _document(Document.empty(meta, api: _api));

  @override
  HttpResponse resource(Resource resource, {Iterable<Resource> included}) =>
      _document(Document(
          ResourceData(_resourceObject(resource),
              links: {'self': Link(_self)},
              included: included?.map(_resourceObject)),
          api: _api));

  @override
  HttpResponse resourceCreated(Resource resource) => _document(
          Document(
              ResourceData(_resourceObject(resource), links: {
                'self': Link(_routing.resource(resource.type, resource.id))
              }),
              api: _api),
          status: 201,
          headers: {
            'Location': _routing.resource(resource.type, resource.id).toString()
          });

  @override
  HttpResponse seeOther(String type, String id) => HttpResponse(303,
      headers: {'Location': _routing.resource(type, id).toString()});

  @override
  HttpResponse toMany(String type, String id, String relationship,
          Iterable<Identifier> identifiers,
          {Iterable<Resource> included}) =>
      _document(Document(
          ToMany(
            identifiers.map(IdentifierObject.fromIdentifier),
            links: {
              'self': Link(_self),
              'related': Link(_routing.related(type, id, relationship))
            },
          ),
          api: _api));

  @override
  HttpResponse toOne(
          Identifier identifier, String type, String id, String relationship,
          {Iterable<Resource> included}) =>
      _document(Document(
          ToOne(
            nullable(IdentifierObject.fromIdentifier)(identifier),
            links: {
              'self': Link(_self),
              'related': Link(_routing.related(type, id, relationship))
            },
          ),
          api: _api));

  @override
  HttpResponse noContent() => HttpResponse(204);

  HttpResponseFactory(this._routing, this._self);

  final Uri _self;
  final Routing _routing;
  final Api _api = Api(version: '1.0');

  HttpResponse _document(Document d,
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
