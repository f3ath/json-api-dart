part of 'server.dart';

const _parser = const JsonApiParser();

abstract class _BaseRequest<T extends RequestTarget> {
  HttpResponse response;
  String allowOrigin = '*';
  Uri uri;
  DocumentBuilder docBuilder;

  T target;

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
}

abstract class _CollectionRequest extends _BaseRequest<CollectionTarget> {}

class _FetchCollection extends _CollectionRequest
    implements FetchCollectionRequest {
  Future call(JsonApiController _) => _.fetchCollection(this);

  Future sendCollection(Collection<Resource> resources) =>
      _write(200, document: docBuilder.collection(resources, target, uri));
}

class _CreateResource extends _CollectionRequest
    implements CreateResourceRequest {
  Resource resource;

  void setBody(Object body) {
    resource = _parser.parseResourceData(body).toResource();
  }

  Future call(JsonApiController _) => _.createResource(this);

  Future sendCreated(Resource resource) {
    final doc = docBuilder.resource(
        resource, ResourceTarget(resource.type, resource.id), uri);
    return _write(201,
        document: doc,
        headers: {'Location': doc.data.resourceObject.self.toString()});
  }
}

class _FetchRelated extends _BaseRequest<RelatedResourceTarget>
    implements FetchRelatedRequest {
  Future call(JsonApiController _) => _.fetchRelated(this);

  Future sendCollection(Collection<Resource> resources) => _write(200,
      document: docBuilder.relatedCollection(resources, target, uri));

  Future sendResource(Resource resource) =>
      _write(200, document: docBuilder.relatedResource(resource, target, uri));
}

abstract class _RelationshipRequest extends _BaseRequest<RelationshipTarget> {
  Future sendToMany(Iterable<Identifier> collection) =>
      _write(200, document: docBuilder.toMany(collection, target, uri));

  Future sendToOne(Identifier id) =>
      _write(200, document: docBuilder.toOne(id, target, uri));
}

class _FetchRelationship extends _RelationshipRequest
    implements FetchRelationshipRequest {
  Future call(JsonApiController _) => _.fetchRelationship(this);
}

class _ReplaceRelationship extends _RelationshipRequest
    implements ReplaceToOneRequest, ReplaceToManyRequest {
  RelationshipTarget target;

  Identifier identifier;
  Iterable<Identifier> identifiers;

  @override
  void setBody(Object body) {
    final r = _parser.parseRelationship(body);
    if (r is ToOne) identifier = r.toIdentifier();
    if (r is ToMany) identifiers = r.toIdentifiers();
  }

  Future call(JsonApiController controller) {
    if (identifiers != null) return controller.replaceToMany(this);
    return controller.replaceToOne(this);
  }
}

class _AddToMany extends _RelationshipRequest implements AddToManyRequest {
  RelationshipTarget target;
  Identifier identifier;
  Iterable<Identifier> identifiers;

  @override
  void setBody(Object body) {
    final r = _parser.parseRelationship(body);
    if (r is ToOne) identifier = r.toIdentifier();
    if (r is ToMany) identifiers = r.toIdentifiers();
  }

  Future call(JsonApiController _) => _.addToMany(this);
}

abstract class _ResourceRequest extends _BaseRequest<ResourceTarget> {
  Future _resource(Resource resource, {Iterable<Resource> included}) => _write(
      200,
      document: docBuilder.resource(resource, target, uri, included: included));
}

class _FetchResource extends _ResourceRequest implements FetchResourceRequest {
  Future call(JsonApiController _) => _.fetchResource(this);

  Future sendResource(Resource resource, {Iterable<Resource> included}) =>
      _resource(resource, included: included);
}

class _DeleteResource extends _ResourceRequest
    implements DeleteResourceRequest {
  Future call(JsonApiController controller) => controller.deleteResource(this);

  Future sendMeta(Map<String, Object> meta) =>
      _write(200, document: Document.empty(meta));
}

class _UpdateResource extends _ResourceRequest
    implements UpdateResourceRequest {
  Resource resource;

  @override
  void setBody(Object body) {
    resource = _parser.parseResourceData(body).resourceObject.toResource();
  }

  Future call(JsonApiController controller) => controller.updateResource(this);

  Future sendUpdated(Resource resource) => _resource(resource);
}
