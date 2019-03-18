part of 'server.dart';

class _JsonApiRouteFactory implements RouteFactory<_BaseRoute> {
  const _JsonApiRouteFactory();

  _BaseRoute collection(String type) => _CollectionRoute(type);

  _BaseRoute related(String type, String id, String relationship) =>
      _RelatedRoute(type, id, relationship);

  _BaseRoute relationship(String type, String id, String relationship) =>
      _RelationshipRoute(type, id, relationship);

  _BaseRoute resource(String type, String id) => _ResourceRoute(type, id);

  _BaseRoute unmatched() => null;
}

abstract class _BaseRoute {
  Uri self(UriBuilder builder, {Map<String, String> parameters = const {}});

  _BaseRequest createRequest(HttpRequest httpRequest);
}

class _CollectionRoute extends _BaseRoute {
  final String type;

  _CollectionRoute(this.type);

  _BaseRequest createRequest(HttpRequest request) {
    switch (request.method) {
      case 'GET':
        return _FetchCollection()..route = this;
      case 'POST':
        return _CreateResource()..route = this;
    }
    throw 'Unexpected method ${request.method}';
  }

  @override
  Uri self(UriBuilder builder, {Map<String, String> parameters = const {}}) =>
      builder.collection(type, parameters: parameters);
}

class _RelatedRoute extends _BaseRoute {
  final String type;
  final String id;
  final String relationship;

  _RelatedRoute(this.type, this.id, this.relationship);

  _BaseRequest createRequest(HttpRequest request) {
    switch (request.method) {
      case 'GET':
        return _FetchRelated()..route = this;
    }
    throw 'Unexpected method ${request.method}';
  }

  @override
  Uri self(UriBuilder builder, {Map<String, String> parameters = const {}}) =>
      builder.related(type, id, relationship, parameters: parameters);
}

class _RelationshipRoute extends _BaseRoute {
  final String type;
  final String id;
  final String relationship;

  _RelationshipRoute(this.type, this.id, this.relationship);

  _BaseRequest createRequest(HttpRequest request) {
    switch (request.method) {
      case 'GET':
        return _FetchRelationship()..route = this;
      case 'PATCH':
        return _ReplaceRelationship()..route = this;
      case 'POST':
        return _AddToMany()..route = this;
    }
    throw 'Unexpected method ${request.method}';
  }

  Uri self(UriBuilder builder, {Map<String, String> parameters = const {}}) =>
      builder.relationship(type, id, relationship, parameters: parameters);

  Uri related(UriBuilder builder, {Map<String, String> params = const {}}) =>
      builder.related(type, id, relationship, parameters: params);
}

class _ResourceRoute extends _BaseRoute {
  final String type;
  final String id;

  _ResourceRoute(this.type, this.id);

  _BaseRequest createRequest(HttpRequest request) {
    switch (request.method) {
      case 'GET':
        return _FetchResource()..route = this;
      case 'DELETE':
        return _DeleteResource()..route = this;
      case 'PATCH':
        return _UpdateResource()..route = this;
    }
    throw 'Unexpected method ${request.method}';
  }

  Uri self(UriBuilder builder, {Map<String, String> parameters = const {}}) =>
      builder.resource(type, id, parameters: parameters);
}
