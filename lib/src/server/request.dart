import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/controller_response.dart';
import 'package:json_api/src/server/target.dart';

abstract class JsonApiRequest<T extends CollectionTarget> {
  JsonApiRequest(this._request, this.target)
      : sort = Sort.fromQueryParameters(_request.uri.queryParametersAll),
        include = Include.fromQueryParameters(_request.uri.queryParametersAll),
        page = Page.fromQueryParameters(_request.uri.queryParametersAll);

  final HttpRequest _request;
  final Include include;
  final Page page;
  final Sort sort;
  final T target;

  Uri get uri => _request.uri;

  Map<String, String> get headers => _request.headers;

  Object decodePayload() => jsonDecode(_request.body);

  bool get isCompound => include.isNotEmpty;

  /// Generates the 'self' link preserving original query parameters
  Uri generateSelfUri(UriFactory factory) => _request
          .uri.queryParameters.isNotEmpty
      ? _self(factory).replace(queryParameters: _request.uri.queryParametersAll)
      : _self(factory);

  Uri _self(UriFactory factory);
}

class RelatedRequest extends JsonApiRequest<RelationshipTarget> {
  RelatedRequest(HttpRequest request, RelationshipTarget target)
      : super(request, target);

  ControllerResponse resourceResponse(Resource resource,
          {List<Resource> include}) =>
      RelatedResourceResponse(this, resource);

  ControllerResponse collectionResponse(Collection<Resource> collection,
          {List<Resource> include}) =>
      RelatedCollectionResponse(this, collection);

  @override
  Uri _self(UriFactory factory) =>
      factory.related(target.type, target.id, target.relationship);
}

class ResourceRequest extends JsonApiRequest<ResourceTarget> {
  ResourceRequest(HttpRequest request, ResourceTarget target)
      : super(request, target);

  ControllerResponse resourceResponse(Resource resource,
          {List<Resource> include}) =>
      PrimaryResourceResponse(this, resource, include: include);

  @override
  Uri _self(UriFactory factory) => factory.resource(target.type, target.id);
}

class RelationshipRequest extends JsonApiRequest<RelationshipTarget> {
  RelationshipRequest(HttpRequest request, RelationshipTarget target)
      : super(request, target);

  ControllerResponse toManyResponse(List<Identifier> identifiers,
          {List<Resource> include}) =>
      ToManyResponse(this, identifiers);

  ControllerResponse toOneResponse(Identifier identifier,
          {List<Resource> include}) =>
      ToOneResponse(this, identifier);

  @override
  Uri _self(UriFactory factory) =>
      factory.relationship(target.type, target.id, target.relationship);
}

class CollectionRequest extends JsonApiRequest<CollectionTarget> {
  CollectionRequest(HttpRequest request, CollectionTarget target)
      : super(request, target);

  ControllerResponse resourceResponse(Resource modified) =>
      CreatedResourceResponse(modified);

  ControllerResponse collectionResponse(Collection<Resource> collection,
          {List<Resource> include}) =>
      PrimaryCollectionResponse(this, collection, include: include);

  @override
  Uri _self(UriFactory factory) => factory.collection(target.type);
}
