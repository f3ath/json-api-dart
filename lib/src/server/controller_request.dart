import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/controller_response.dart';

class _Base {
  _Base(this.request)
      : sort = Sort.fromQueryParameters(request.uri.queryParametersAll),
        include = Include.fromQueryParameters(request.uri.queryParametersAll),
        page = Page.fromQueryParameters(request.uri.queryParametersAll);

  final HttpRequest request;
  final Include include;
  final Page page;
  final Sort sort;

  bool get isCompound => include.isNotEmpty;
}

class RelatedRequest extends _Base {
  RelatedRequest(HttpRequest request, this.type, this.id, this.relationship)
      : super(request);

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

class ResourceRequest extends _Base {
  ResourceRequest(HttpRequest request, this.type, this.id) : super(request);

  final String type;

  final String id;

  ControllerResponse resourceResponse(Resource resource,
          {List<Resource> include}) =>
      ResourceResponse(resource, include: include);
}

class RelationshipRequest extends _Base {
  RelationshipRequest(
      HttpRequest request, this.type, this.id, this.relationship)
      : super(request);

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

class CollectionRequest extends _Base {
  CollectionRequest(HttpRequest request, this.type) : super(request);

  final String type;

  ControllerResponse resourceResponse(Resource modified) =>
      CreatedResourceResponse(modified);

  ControllerResponse collectionResponse(Collection<Resource> collection,
          {List<Resource> include}) =>
      CollectionResponse(collection, include: include);
}
