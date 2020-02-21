import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/document_factory.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:json_api/src/server/response_converter.dart';

/// An implementation of [ResponseConverter] converting to [HttpResponse].
class HttpResponseFactory implements ResponseConverter<HttpResponse> {
  @override
  HttpResponse error(Iterable<ErrorObject> errors, int statusCode,
          Map<String, String> headers) =>
      _ok(_doc.error(errors), status: statusCode, headers: headers);

  @override
  HttpResponse collection(Iterable<Resource> collection,
      {int total,
      Iterable<Resource> included,
      Pagination pagination = const NoPagination()}) {
    return _ok(_doc.collection(collection,
        total: total, included: included, pagination: pagination));
  }

  @override
  HttpResponse accepted(Resource resource) =>
      _ok(_doc.resource(resource), status: 202, headers: {
        'Content-Location':
            _routing.resource(resource.type, resource.id).toString()
      });

  @override
  HttpResponse meta(Map<String, Object> meta) => _ok(_doc.empty(meta));

  @override
  HttpResponse resource(Resource resource, {Iterable<Resource> included}) =>
      _ok(_doc.resource(resource, included: included));

  @override
  HttpResponse resourceCreated(Resource resource) =>
      _ok(_doc.resourceCreated(resource), status: 201, headers: {
        'Location': _routing.resource(resource.type, resource.id).toString()
      });

  @override
  HttpResponse seeOther(String type, String id) => HttpResponse(303,
      headers: {'Location': _routing.resource(type, id).toString()});

  @override
  HttpResponse toMany(String type, String id, String relationship,
          Iterable<Identifier> identifiers,
          {Iterable<Resource> included}) =>
      _ok(_doc.toMany(type, id, relationship, identifiers, included: included));

  @override
  HttpResponse toOne(
          Identifier identifier, String type, String id, String relationship,
          {Iterable<Resource> included}) =>
      _ok(_doc.toOne(identifier, type, id, relationship, included: included));

  @override
  HttpResponse noContent() => HttpResponse(204);

  HttpResponseFactory(this._doc, this._routing);

  final RouteFactory _routing;
  final DocumentFactory _doc;

  HttpResponse _ok(Document d,
          {int status = 200, Map<String, String> headers = const {}}) =>
      HttpResponse(status,
          body: jsonEncode(d),
          headers: {...headers, 'Content-Type': Document.contentType});
}
