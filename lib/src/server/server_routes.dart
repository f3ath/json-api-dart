part of 'server.dart';

class _JsonApiRouteFactory implements RouteFactory<_Route> {
  const _JsonApiRouteFactory();

  _Route collection(String type) => _Route(CollectionTarget(type));

  _Route related(String type, String id, String relationship) =>
      _Route(RelatedResourceTarget(type, id, relationship));

  _Route relationship(String type, String id, String relationship) =>
      _Route(RelationshipTarget(type, id, relationship));

  _Route resource(String type, String id) => _Route(ResourceTarget(type, id));

  _Route unmatched() => null;
}

class _Route<T extends RequestTarget> {
  final T target;

  _Route(this.target);

  _BaseRequest createRequest(HttpRequest request) {
    return _createRequest(request)..target = target;
  }

  _BaseRequest _createRequest(HttpRequest request) {
    final t = target;
    if (t is CollectionTarget) {
      switch (request.method) {
        case 'GET':
          return _FetchCollection();
        case 'POST':
          return _CreateResource();
      }
      throw 'Unexpected method ${request.method}';
    }
    if (t is ResourceTarget) {
      switch (request.method) {
        case 'GET':
          return _FetchResource();
        case 'DELETE':
          return _DeleteResource();
        case 'PATCH':
          return _UpdateResource();
      }
      throw 'Unexpected method ${request.method}';
    }
    if (t is RelatedResourceTarget) {
      switch (request.method) {
        case 'GET':
          return _FetchRelated();
      }
      throw 'Unexpected method ${request.method}';
    }
    if (t is RelationshipTarget) {
      switch (request.method) {
        case 'GET':
          return _FetchRelationship();
        case 'PATCH':
          return _ReplaceRelationship();
        case 'POST':
          return _AddToMany();
      }
      throw 'Unexpected method ${request.method}';
    }
    throw 'Unexpected target ${target}';
  }
}
