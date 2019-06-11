import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_data.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request_target.dart';
import 'package:json_api/src/server/response.dart';

abstract class _Request implements ControllerDispatcher {
  RequestTarget get target;
}

class _FetchCollectionRequest extends _Request
    implements FetchCollectionRequest {
  final CollectionTarget target;

  _FetchCollectionRequest(this.target);

  @override
  FutureOr<Response> dispatchCall(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchCollection(this, query);
}

class _FetchResourceRequest extends _Request implements FetchResourceRequest {
  final ResourceTarget target;

  _FetchResourceRequest(this.target);

  @override
  FutureOr<Response> dispatchCall(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchResource(this, query);
}

class _FetchRelatedRequest extends _Request implements FetchRelatedRequest {
  final RelatedTarget target;

  _FetchRelatedRequest(this.target);

  @override
  FutureOr<Response> dispatchCall(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelated(this, query);
}

class _FetchRelationshipRequest extends _Request
    implements FetchRelationshipRequest {
  final RelationshipTarget target;

  _FetchRelationshipRequest(this.target);

  @override
  FutureOr<Response> dispatchCall(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelationship(this, query);
}

class _DeleteResourceRequest extends _Request implements DeleteResourceRequest {
  final ResourceTarget target;

  _DeleteResourceRequest(this.target);

  @override
  FutureOr<Response> dispatchCall(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.deleteResource(this);
}

class _UpdateResourceRequest extends _Request implements UpdateResourceRequest {
  final ResourceTarget target;

  _UpdateResourceRequest(this.target);

  @override
  FutureOr<Response> dispatchCall(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.updateResource(this,
          Document.decodeJson(payload, ResourceData.decodeJson).data.unwrap());
}

class _CreateResourceRequest extends _Request implements CreateResourceRequest {
  final CollectionTarget target;

  _CreateResourceRequest(this.target);

  @override
  FutureOr<Response> dispatchCall(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.createResource(this,
          Document.decodeJson(payload, ResourceData.decodeJson).data.unwrap());
}

class _UpdateRelationshipRequest extends _Request
    implements UpdateRelationshipRequest {
  final RelationshipTarget target;

  _UpdateRelationshipRequest(this.target);

  @override
  FutureOr<Response> dispatchCall(Controller controller,
      Map<String, List<String>> query, Object payload) async {
    final rel = Relationship.decodeJson(payload);
    if (rel is ToOne) {
      return controller.replaceToOne(this, rel.unwrap());
    }
    if (rel is ToMany) {
      return controller.replaceToMany(this, rel.identifiers);
    }
    return ErrorResponse.badRequest([]); //TODO: meaningful error
  }
}

class _AddToManyRequest extends _Request implements AddToManyRequest {
  final RelationshipTarget target;

  _AddToManyRequest(this.target);

  @override
  FutureOr<Response> dispatchCall(Controller controller,
      Map<String, List<String>> query, Object payload) async {
    final rel = Relationship.decodeJson(payload);
    if (rel is ToMany) {
      return controller.addToMany(this, rel.identifiers);
    }
    return ErrorResponse.badRequest([]); //TODO: meaningful error
  }
}

class _InvalidRequest extends _Request {
  final target = null;
  final Response _response;

  _InvalidRequest(this._response);

  @override
  Response dispatchCall(Controller controller, Map<String, List<String>> query,
          Object payload) =>
      _response;
}

class DefaultRequestFactory implements ControllerDispatcherFactory {
  const DefaultRequestFactory();

  @override
  ControllerDispatcher makeFetchCollectionRequest(CollectionTarget target) =>
      _FetchCollectionRequest(target);

  @override
  ControllerDispatcher makeCreateResourceRequest(CollectionTarget target) =>
      _CreateResourceRequest(target);

  @override
  ControllerDispatcher makeFetchResourceRequest(ResourceTarget target) =>
      _FetchResourceRequest(target);

  @override
  ControllerDispatcher makeDeleteResourceRequest(ResourceTarget target) =>
      _DeleteResourceRequest(target);

  @override
  ControllerDispatcher makeUpdateResourceRequest(ResourceTarget target) =>
      _UpdateResourceRequest(target);

  @override
  ControllerDispatcher makeFetchRelationshipRequest(RelationshipTarget target) =>
      _FetchRelationshipRequest(target);

  @override
  ControllerDispatcher makeAddToManyRequest(RelationshipTarget target) =>
      _AddToManyRequest(target);

  @override
  ControllerDispatcher makeFetchRelatedRequest(RelatedTarget target) =>
      _FetchRelatedRequest(target);

  @override
  ControllerDispatcher makeUpdateRelationshipRequest(RelationshipTarget target) =>
      _UpdateRelationshipRequest(target);

  @override
  ControllerDispatcher makeInvalidRequest(RequestTarget target) =>
      _InvalidRequest(ErrorResponse.methodNotAllowed([]));
}
