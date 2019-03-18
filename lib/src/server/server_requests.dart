part of 'server.dart';

abstract class _BaseRequest {
  HttpResponse response;
  bool allowOrigin;
  Uri uri;
  DocumentBuilder docBuilder;

  void setBody(Object body) {}

  Future _error(int status, Iterable<JsonApiError> errors) =>
      _write(status, document: docBuilder.error(errors));

  Future call(JsonApiController controller);

  Future sendNoContent() => _write(204);

  Future errorNotFound([Iterable<JsonApiError> errors]) => _error(404, errors);

  Future errorConflict(Iterable<JsonApiError> errors) => _error(409, errors);

  Future errorForbidden(Iterable<JsonApiError> errors) => _error(403, errors);

  Future _write(int status,
      {Document document, Map<String, String> headers = const {}}) {
    response.statusCode = status;
    headers.forEach(response.headers.add);
    if (allowOrigin != null) {
      response.headers.set('Access-Control-Allow-Origin', allowOrigin);
    }
    if (document != null) {
      response.write(json.encode(document));
    }
    return response.close();
  }

  Future _collection(_CollectionRoute route, Iterable<Resource> resource,
          {Page page}) =>
      _write(200,
          document:
              docBuilder.collection(resource, route.type, uri, page: page));

  Future _relatedCollection(_RelatedRoute route, Iterable<Resource> collection,
          {Page page}) =>
      _write(200,
          document: docBuilder.relatedCollection(
              collection, route.type, route.id, route.relationship, uri,
              page: page));

  Future _relatedResource(_RelatedRoute route, Resource resource) => _write(200,
      document: docBuilder.relatedResource(
          resource, route.type, route.id, route.relationship, uri));

  Future _resource(_ResourceRoute route, Resource resource,
          {Iterable<Resource> included}) =>
      _write(200,
          document: docBuilder.resource(resource, route.type, route.id, uri,
              included: included));

  Future _toMany(_RelationshipRoute route, Iterable<Identifier> collection) =>
      _write(200,
          document: docBuilder.toMany(
              collection, route.type, route.id, route.relationship, uri));

  Future _toOne(_RelationshipRoute route, Identifier identifier) => _write(200,
      document: docBuilder.toOne(
          identifier, route.type, route.id, route.relationship, uri));

  Future _meta(_ResourceRoute route, Map<String, Object> meta) =>
      _write(200, document: Document.empty(meta));

  Future _created(_CollectionRoute route, Resource resource) {
    final doc = docBuilder.resource(resource, route.type, resource.id, uri);
    return _write(201,
        document: doc,
        headers: {'Location': doc.data.resourceJson.self.toString()});
  }
}

abstract class _CollectionRequest extends _BaseRequest {
  _CollectionRoute route;

  String get type => route.type;
}

class _FetchCollection extends _CollectionRequest
    implements FetchCollectionRequest {
  Future call(JsonApiController controller) => controller.fetchCollection(this);

  Future sendCollection(Iterable<Resource> resources, {Page page}) =>
      _collection(route, resources, page: page);
}

class _CreateResource extends _CollectionRequest
    implements CreateResourceRequest {
  Resource resource;

  void setBody(Object body) {
    resource = ResourceData.parse(body).toResource();
  }

  Future call(JsonApiController controller) => controller.createResource(this);

  Future sendCreated(Resource resource) => _created(route, resource);
}

class _FetchRelated extends _BaseRequest implements FetchRelatedRequest {
  _RelatedRoute route;

  String get type => route.type;

  String get id => route.id;

  String get relationship => route.relationship;

  Future call(JsonApiController controller) => controller.fetchRelated(this);

  Future sendCollection(Iterable<Resource> collection) =>
      _relatedCollection(route, collection);

  Future sendResource(Resource resource) => _relatedResource(route, resource);
}

abstract class _RelationshipRequest extends _BaseRequest {
  _RelationshipRoute route;

  String get type => route.type;

  String get id => route.id;

  String get relationship => route.relationship;
}

class _FetchRelationship extends _RelationshipRequest
    implements FetchRelationshipRequest {
  Future call(JsonApiController controller) =>
      controller.fetchRelationship(this);

  Future sendToMany(Iterable<Identifier> collection) =>
      _toMany(route, collection);

  Future sendToOne(Identifier id) => _toOne(route, id);
}

class _ReplaceRelationship extends _RelationshipRequest
    implements ReplaceToOneRequest, ReplaceToManyRequest {
  Identifier identifier;
  Iterable<Identifier> identifiers;

  @override
  void setBody(Object body) {
    final r = Relationship.parse(body);
    if (r is ToOne) identifier = r.toIdentifier();
    if (r is ToMany) identifiers = r.toIdentifiers();
  }

  Future call(JsonApiController controller) {
    if (identifiers != null) return controller.replaceToMany(this);
    return controller.replaceToOne(this);
  }

  Future sendToMany(Iterable<Identifier> collection) =>
      _toMany(route, collection);

  Future sendToOne(Identifier id) => _toOne(route, id);
}

class _AddToMany extends _RelationshipRequest implements AddToManyRequest {
  Identifier identifier;
  Iterable<Identifier> identifiers;

  @override
  void setBody(Object body) {
    final r = Relationship.parse(body);
    if (r is ToOne) identifier = r.toIdentifier();
    if (r is ToMany) identifiers = r.toIdentifiers();
  }

  Future call(JsonApiController controller) => controller.addToMany(this);

  Future sendToMany(Iterable<Identifier> collection) =>
      _toMany(route, collection);
}

abstract class _ResourceRequest extends _BaseRequest {
  _ResourceRoute route;

  String get type => route.type;

  String get id => route.id;
}

class _FetchResource extends _ResourceRequest implements FetchResourceRequest {
  Future call(JsonApiController controller) => controller.fetchResource(this);

  Future sendResource(Resource resource, {Iterable<Resource> included}) =>
      _resource(route, resource, included: included);
}

class _DeleteResource extends _ResourceRequest
    implements DeleteResourceRequest {
  Future call(JsonApiController controller) => controller.deleteResource(this);

  Future sendMeta(Map<String, Object> meta) => _meta(route, meta);
}

class _UpdateResource extends _ResourceRequest
    implements UpdateResourceRequest {
  Resource resource;

  @override
  void setBody(Object body) {
    resource = ResourceData.parse(body).resourceJson.toResource();
  }

  Future call(JsonApiController controller) => controller.updateResource(this);

  Future sendUpdated(Resource resource) => _resource(route, resource);
}
