import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/parser.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/document_builder.dart';
import 'package:json_api/src/server/request_target.dart';
import 'package:json_api/src/server/router.dart';

class JsonApiServer {
  final URLDesign url;
  final JsonApiController controller;
  final DocumentBuilder builder;

  JsonApiServer(this.url, this.controller, this.builder);

  Future<void> process(HttpRequest request) async {
    const parser = const JsonApiParser();
    final target = await url.getTarget(request.requestedUri);
    if (target == null) {
      request.response.statusCode = 404;
      return request.response.close();
    }
    final bodyString = await request.transform(utf8.decoder).join();
    final body = bodyString.isNotEmpty ? json.decode(bodyString) : null;

    if (target is CollectionTarget) {
      final rs = _CollectionResponse(target, request, builder);
      switch (request.method) {
        case 'GET':
          return controller.fetchCollection(
              ControllerRequest(request, target), rs);
        case 'POST':
          return controller.createResource(
              ControllerRequest(request, target,
                  payload: parser.parseResourceData(body).toResource()),
              rs);
      }
    } else if (target is ResourceTarget) {
      final rs = _ResourceResponse(target, request, builder, url);
      switch (request.method) {
        case 'GET':
          return controller.fetchResource(
              ControllerRequest(request, target), rs);
        case 'DELETE':
          return controller.deleteResource(
              ControllerRequest(request, target), rs);
        case 'PATCH':
          return controller.updateResource(
              ControllerRequest(request, target,
                  payload: parser.parseResourceData(body).toResource()),
              rs);
      }
    } else if (target is RelatedTarget && request.method == 'GET') {
      return controller.fetchRelated(ControllerRequest(request, target),
          _RelatedResponse(target, request, builder));
    } else if (target is RelationshipTarget) {
      final rs = _RelationshipResponse(target, request, builder);
      switch (request.method) {
        case 'GET':
          return controller.fetchRelationship(
              ControllerRequest(request, target), rs);
        case 'PATCH':
          final relationship = parser.parseRelationship(body);
          if (relationship is ToOne) {
            return controller.replaceToOne(
                ControllerRequest(request, target,
                    payload: relationship.toIdentifier()),
                rs);
          }
          if (relationship is ToMany) {
            return controller.replaceToMany(
                ControllerRequest(request, target,
                    payload: relationship.toIdentifiers()),
                rs);
          }
          break;
        case 'POST':
          final relationship = parser.parseRelationship(body);
          if (relationship is ToMany) {
            return controller.addToMany(
                ControllerRequest(request, target,
                    payload: relationship.toIdentifiers()),
                rs);
          }
      }
    }
    throw 'Unable to create request for ${target}:${request.method}';
  }
}

abstract class _Response<T extends RequestTarget> {
  final headers = <String, String>{'Access-Control-Allow-Origin': '*'};
  final HttpRequest request;

  final DocumentBuilder docBuilder;

  final T target;

  _Response(this.target, this.request, this.docBuilder);

  Future sendNoContent() => _write(204);

  Future<void> sendAccepted(Resource resource) {
    final doc = docBuilder.resource(resource,
        ResourceTarget(resource.type, resource.id), request.requestedUri);
    headers['Content-Location'] = doc.data.resourceObject.self.uri.toString();
    return _write(202, document: doc);
  }

  Future errorBadRequest(Iterable<JsonApiError> errors) => _error(400, errors);

  Future errorForbidden(Iterable<JsonApiError> errors) => _error(403, errors);

  Future errorNotFound([Iterable<JsonApiError> errors]) => _error(404, errors);

  Future errorConflict(Iterable<JsonApiError> errors) => _error(409, errors);

  Future sendMeta(Map<String, Object> meta) =>
      _write(200, document: Document.empty(meta));

  Future _error(int status, Iterable<JsonApiError> errors) =>
      _write(status, document: docBuilder.error(errors));

  Future _write(int status, {Document document}) {
    request.response.statusCode = status;
    headers.forEach(request.response.headers.add);
    if (document != null) {
      request.response.write(json.encode(document));
    }
    return request.response.close();
  }
}

class _CollectionResponse extends _Response<CollectionTarget>
    implements FetchCollectionResponse, CreateResourceResponse {
  _CollectionResponse(
      CollectionTarget target, HttpRequest request, DocumentBuilder docBuilder)
      : super(target, request, docBuilder);

  Future sendCollection(Collection<Resource> resources) => _write(200,
      document: docBuilder.collection(resources, target, request.requestedUri));

  Future sendCreated(Resource resource) {
    final doc = docBuilder.resource(resource,
        ResourceTarget(resource.type, resource.id), request.requestedUri);
    headers['Location'] = doc.data.resourceObject.self.uri.toString();
    return _write(201, document: doc);
  }
}

class _RelatedResponse extends _Response<RelatedTarget>
    implements FetchRelatedResponse {
  _RelatedResponse(
      RelatedTarget target, HttpRequest request, DocumentBuilder docBuilder)
      : super(target, request, docBuilder);

  Future sendCollection(Collection<Resource> resources) => _write(200,
      document: docBuilder.relatedCollection(
          resources, target, request.requestedUri));

  Future sendResource(Resource resource) => _write(200,
      document:
          docBuilder.relatedResource(resource, target, request.requestedUri));
}

class _RelationshipResponse extends _Response<RelationshipTarget>
    implements
        FetchRelationshipResponse,
        ReplaceToOneResponse,
        ReplaceToManyResponse,
        AddToManyResponse {
  _RelationshipResponse(RelationshipTarget target, HttpRequest request,
      DocumentBuilder docBuilder)
      : super(target, request, docBuilder);

  Future sendToMany(Iterable<Identifier> collection) => _write(200,
      document: docBuilder.toMany(collection, target, request.requestedUri));

  Future sendToOne(Identifier id) =>
      _write(200, document: docBuilder.toOne(id, target, request.requestedUri));
}

class _ResourceResponse extends _Response<ResourceTarget>
    implements
        FetchResourceResponse,
        DeleteResourceResponse,
        UpdateResourceResponse {
  final URLDesign urlDesign;

  _ResourceResponse(ResourceTarget target, HttpRequest request,
      DocumentBuilder docBuilder, this.urlDesign)
      : super(target, request, docBuilder);

  Future _resource(Resource resource, {Iterable<Resource> included}) =>
      _write(200,
          document: docBuilder.resource(resource, target, request.requestedUri,
              included: included));

  Future sendResource(Resource resource, {Iterable<Resource> included}) =>
      _resource(resource, included: included);

  Future sendUpdated(Resource resource) => _resource(resource);

  @override
  Future<void> sendSeeOther(Resource resource) {
    headers['Location'] = urlDesign
        .resource(ResourceTarget(resource.type, resource.id))
        .toString();
    return _write(303);
  }
}
