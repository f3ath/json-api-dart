import 'package:json_api/src/server/request/request.dart';

abstract class RequestTarget {
  String get type;

  /// Returns the request for the given [method], or null otherwise
  Request getRequest(String method);
}

class CollectionTarget implements RequestTarget {
  final String type;

  const CollectionTarget(this.type);

  @override
  Request getRequest(String method) {
    method = method.toUpperCase();
    if (method == 'GET') return FetchCollection(this);
    if (method == 'POST') return CreateResource(this);
    return null;
  }
}

class ResourceTarget implements RequestTarget {
  final String type;
  final String id;

  const ResourceTarget(this.type, this.id);

  @override
  Request getRequest(String method) {
    method = method.toUpperCase();
    if (method == 'GET') return FetchResource(this);
    if (method == 'DELETE') return DeleteResource(this);
    if (method == 'PATCH') return UpdateResource(this);
    return null;
  }
}

class RelationshipTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);

  @override
  Request getRequest(String method) {
    method = method.toUpperCase();
    if (method == 'GET') return FetchRelationship(this);
    if (method == 'PATCH') return UpdateRelationship(this);
    if (method == 'POST') return AddToMany(this);
    return null;
  }
}

class RelatedTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelatedTarget(this.type, this.id, this.relationship);

  @override
  Request getRequest(String method) {
    method = method.toUpperCase();
    if (method == 'GET') return FetchRelated(this);
    return null;
  }
}
