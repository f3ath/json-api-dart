import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/controller_response.dart';

class RelatedRequest {
  RelatedRequest(this.request, this.type, this.id, this.relationship);

  final HttpRequest request;

  final String type;

  final String id;

  final String relationship;

  ControllerResponse resourceResponse(Resource resource,
          {List<Resource> include}) =>
      ResourceResponse(resource);

  ControllerResponse collectionResponse(Collection<Resource> collection,
          {List<Resource> include}) =>
      CollectionResponse(collection);
}

class ResourceRequest {
  ResourceRequest(this.request, this.type, this.id);

  final HttpRequest request;

  final String type;

  final String id;

  ControllerResponse resourceResponse(Resource resource,
          {List<Resource> include}) =>
      ResourceResponse(resource, include: include);
}

class RelationshipRequest {
  RelationshipRequest(this.request, this.type, this.id, this.relationship);

  final HttpRequest request;

  final String type;

  final String id;

  final String relationship;

  ControllerResponse toManyResponse(List<Identifier> identifiers,
          {List<Resource> include}) =>
      ToManyResponse(identifiers);

  ControllerResponse toOneResponse(Identifier identifier,
          {List<Resource> include}) =>
      ToOneResponse(identifier);
}

class CollectionRequest {
  CollectionRequest(this.request, this.type);

  final HttpRequest request;

  final String type;

  ControllerResponse resourceResponse(Resource modified) =>
      CreatedResourceResponse(modified);

  ControllerResponse collectionResponse(Collection<Resource> collection,
          {List<Resource> include}) =>
      CollectionResponse(collection, include: include);
}
