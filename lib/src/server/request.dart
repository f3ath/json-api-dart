import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_data.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request_target.dart';
import 'package:json_api/src/server/response.dart';

class DefaultRequestFactory implements RequestFactory {
  const DefaultRequestFactory();

  @override
  Request makeFetchCollectionRequest(CollectionTarget target) =>
      _FetchCollectionRequest(target);

  @override
  Request makeCreateResourceRequest(CollectionTarget target) =>
      _CreateResourceRequest(target);

  @override
  Request makeFetchResourceRequest(ResourceTarget target) =>
      _FetchResourceRequest(target);

  @override
  Request makeDeleteResourceRequest(ResourceTarget target) =>
      _DeleteResourceRequest(target);

  @override
  Request makeUpdateResourceRequest(ResourceTarget target) =>
      _UpdateResourceRequest(target);

  @override
  Request makeFetchRelationshipRequest(RelationshipTarget target) =>
      _FetchRelationshipRequest(target);

  @override
  Request makeAddToManyRequest(RelationshipTarget target) =>
      _AddToManyRequest(target);

  @override
  Request makeFetchRelatedRequest(RelatedTarget target) =>
      _FetchRelatedRequest(target);

  @override
  Request makeUpdateRelationshipRequest(RelationshipTarget target) =>
      _UpdateRelationshipRequest(target);

  @override
  Request makeInvalidRequest(RequestTarget target) =>
      _InvalidRequest(ErrorResponse.methodNotAllowed([]));
}

class _FetchCollectionRequest implements Request, FetchCollectionRequest {
  final CollectionTarget target;

  _FetchCollectionRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchCollection(this, query);

  @override
  String get type => target.type;
}

class _FetchResourceRequest implements Request, FetchResourceRequest {
  final ResourceTarget target;

  _FetchResourceRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchResource(this, query);

  @override
  String get type => target.type;
}

class _FetchRelatedRequest implements Request, FetchRelatedRequest {
  final RelatedTarget target;

  _FetchRelatedRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelated(this, query);

  @override
  String get type => target.type;

  @override
  String get id => target.id;
}

class _FetchRelationshipRequest implements Request, FetchRelationshipRequest {
  final RelationshipTarget target;

  _FetchRelationshipRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelationship(this, query);

  @override
  String get type => target.type;
}

class _DeleteResourceRequest implements Request, DeleteResourceRequest {
  final ResourceTarget target;

  _DeleteResourceRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.deleteResource(this);

  @override
  String get type => target.type;
}

class _UpdateResourceRequest implements Request, UpdateResourceRequest {
  final ResourceTarget target;

  _UpdateResourceRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.updateResource(this,
          Document.decodeJson(payload, ResourceData.decodeJson).data.unwrap());

  @override
  String get type => target.type;
}

class _CreateResourceRequest implements Request, CreateResourceRequest {
  final CollectionTarget target;

  _CreateResourceRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.createResource(this,
          Document.decodeJson(payload, ResourceData.decodeJson).data.unwrap());

  @override
  String get type => target.type;
}

class _UpdateRelationshipRequest implements Request, UpdateRelationshipRequest {
  final RelationshipTarget target;

  _UpdateRelationshipRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
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

  @override
  String get type => target.type;
}

class _AddToManyRequest implements Request, AddToManyRequest {
  final RelationshipTarget target;

  _AddToManyRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
      Map<String, List<String>> query, Object payload) async {
    final rel = Relationship.decodeJson(payload);
    if (rel is ToMany) {
      return controller.addToMany(this, rel.identifiers);
    }
    return ErrorResponse.badRequest([]); //TODO: meaningful error
  }

  @override
  String get type => target.type;
}

class _InvalidRequest implements Request {
  final target = null;
  final Response _response;

  _InvalidRequest(this._response);

  @override
  Response call(Controller controller, Map<String, List<String>> query,
          Object payload) =>
      _response;
}
