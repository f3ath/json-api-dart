import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/document_factory.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:json_api/src/server/relationship_target.dart';
import 'package:json_api/src/server/resource_target.dart';
import 'package:json_api/src/server/response_converter.dart';

/// An implementation of [ResponseConverter] converting to [HttpResponse].
class HttpResponseConverter implements ResponseConverter<HttpResponse> {
  HttpResponseConverter(this._doc, this._routing);

  final RouteFactory _routing;
  final DocumentFactory _doc;

  @override
  HttpResponse error(Iterable<ErrorObject> errors, int statusCode,
          Map<String, String> headers) =>
      _ok(_doc.error(errors), status: statusCode, headers: headers);

  @override
  HttpResponse collection(Iterable<Resource> resources,
      {int total,
      Iterable<Resource> included,
      Pagination pagination = const NoPagination()}) {
    return _ok(_doc.collection(resources,
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
  HttpResponse seeOther(ResourceTarget target) => HttpResponse(303, headers: {
        'Location': _routing.resource(target.type, target.id).toString()
      });

  @override
  HttpResponse toMany(
          RelationshipTarget target, Iterable<Identifier> identifiers,
          {Iterable<Resource> included}) =>
      _ok(_doc.toMany(target, identifiers, included: included));

  @override
  HttpResponse toOne(RelationshipTarget target, Identifier identifier,
          {Iterable<Resource> included}) =>
      _ok(_doc.toOne(target, identifier, included: included));

  @override
  HttpResponse noContent() => HttpResponse(204);

  HttpResponse _ok(Document d,
          {int status = 200, Map<String, String> headers = const {}}) =>
      HttpResponse(status,
          body: jsonEncode(d),
          headers: {...headers, 'Content-Type': Document.contentType});
}
