import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller_request.dart';
import 'package:json_api/src/server/resolvable.dart';

abstract class Target {
  List<String> get allowedMethods;

  Resolvable convertRequest(HttpRequest request);
}

class CollectionTarget implements Target {
  CollectionTarget(this.type);

  final String type;

  @override
  final allowedMethods = ['GET', 'POST'];

  @override
  Resolvable convertRequest(HttpRequest request) {
    if (request.isGet) {
      return FetchCollection(CollectionRequest(request, type));
    }
    if (request.isPost) {
      return CreateResource(CollectionRequest(request, type));
    }
    throw ArgumentError();
  }
}

class ResourceTarget implements Target {
  ResourceTarget(this.type, this.id);

  final String type;
  final String id;

  @override
  final allowedMethods = ['DELETE', 'GET', 'PATCH'];

  @override
  Resolvable convertRequest(HttpRequest request) {
    if (request.isDelete) {
      return DeleteResource(ResourceRequest(request, type, id));
    }
    if (request.isGet) {
      return FetchResource(ResourceRequest(request, type, id));
    }
    if (request.isPatch) {
      return UpdateResource(ResourceRequest(request, type, id));
    }
    throw ArgumentError();
  }
}

class RelatedTarget implements Target {
  RelatedTarget(this.type, this.id, this.relationship);

  final String type;
  final String id;
  final String relationship;

  @override
  final allowedMethods = ['GET'];

  @override
  Resolvable convertRequest(HttpRequest request) {
    if (request.isGet) {
      return FetchRelated(RelatedRequest(request, type, id, relationship));
    }
    throw ArgumentError();
  }
}

class RelationshipTarget implements Target {
  RelationshipTarget(this.type, this.id, this.relationship);

  final String type;
  final String id;
  final String relationship;

  @override
  final allowedMethods = ['DELETE', 'GET', 'PATCH', 'POST'];

  @override
  Resolvable convertRequest(HttpRequest request) {
    if (request.isDelete) {
      return DeleteFromRelationship(
          RelationshipRequest(request, type, id, relationship));
    }
    if (request.isGet) {
      return FetchRelationship(
          RelationshipRequest(request, type, id, relationship));
    }
    if (request.isPatch) {
      return ReplaceRelationship(
          RelationshipRequest(request, type, id, relationship));
    }
    if (request.isPost) {
      return AddToRelationship(
          RelationshipRequest(request, type, id, relationship));
    }
    throw ArgumentError();
  }
}

class TargetFactory implements MatchHandler {
  Target target;

  @override
  void collection(String type) {
    target = CollectionTarget(type);
  }

  @override
  void related(String type, String id, String relationship) {
    target = RelatedTarget(type, id, relationship);
  }

  @override
  void relationship(String type, String id, String relationship) {
    target = RelationshipTarget(type, id, relationship);
  }

  @override
  void resource(String type, String id) {
    target = ResourceTarget(type, id);
  }
}
