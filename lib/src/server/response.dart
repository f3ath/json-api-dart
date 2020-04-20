import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/routing/target.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/response_factory.dart';

abstract class Response {
  HttpResponse convert(ResponseFactory f);
}

class ExtraHeaders implements Response {
  ExtraHeaders(this._response, this._headers);

  final Response _response;
  final Map<String, String> _headers;

  @override
  HttpResponse convert(ResponseFactory f) {
    final r = _response.convert(f);
    return HttpResponse(r.statusCode,
        body: r.body, headers: {...r.headers, ..._headers});
  }
}

class ErrorResponse implements Response {
  ErrorResponse(this.status, this.errors);

  final int status;
  final Iterable<ErrorObject> errors;

  @override
  HttpResponse convert(ResponseFactory f) => f.error(status, errors: errors);
}

class NoContentResponse implements Response {
  NoContentResponse();

  @override
  HttpResponse convert(ResponseFactory f) => f.noContent();
}

class PrimaryResourceResponse implements Response {
  PrimaryResourceResponse(this.request, this.resource, {this.include});

  final Request<ResourceTarget> request;
  final Resource resource;
  final List<Resource> include;

  @override
  HttpResponse convert(ResponseFactory f) =>
      f.primaryResource(request, resource, include: include);
}

class RelatedResourceResponse implements Response {
  RelatedResourceResponse(this.request, this.resource, {this.include});

  final Request<RelatedTarget> request;
  final Resource resource;
  final Iterable<Resource> include;

  @override
  HttpResponse convert(ResponseFactory f) =>
      f.relatedResource(request, resource, include: include);
}

class CreatedResourceResponse implements Response {
  CreatedResourceResponse(this.request, this.resource);

  final Request<CollectionTarget> request;
  final Resource resource;

  @override
  HttpResponse convert(ResponseFactory f) =>
      f.createdResource(request, resource);
}

class PrimaryCollectionResponse implements Response {
  PrimaryCollectionResponse(this.request, this.collection, {this.include});

  final Request<CollectionTarget> request;
  final Collection<Resource> collection;
  final Iterable<Resource> include;

  @override
  HttpResponse convert(ResponseFactory f) =>
      f.primaryCollection(request, collection, include: include);
}

class RelatedCollectionResponse implements Response {
  RelatedCollectionResponse(this.request, this.collection, {this.include});

  final Request<RelatedTarget> request;
  final Collection<Resource> collection;
  final List<Resource> include;

  @override
  HttpResponse convert(ResponseFactory f) =>
      f.relatedCollection(request, collection, include: include);
}

class ToOneResponse implements Response {
  ToOneResponse(this.request, this.identifier);

  final Request<RelationshipTarget> request;
  final Identifier identifier;

  @override
  HttpResponse convert(ResponseFactory f) =>
      f.relationshipToOne(request, identifier);
}

class ToManyResponse implements Response {
  ToManyResponse(this.request, this.identifiers);

  final Request<RelationshipTarget> request;
  final Iterable<Identifier> identifiers;

  @override
  HttpResponse convert(ResponseFactory f) =>
      f.relationshipToMany(request, identifiers);
}
