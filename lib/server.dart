import 'dart:math';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/links.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/response.dart';

export 'package:json_api/src/server/links.dart';
export 'package:json_api/src/server/request.dart';

typedef JsonApiRequest<R> ActionResolver<R>(R request);

class JsonApiServer<R> implements JsonApiController<R> {
  final ResourceController<R> resource;
  final ActionResolver<R> resolver;
  final Links links;

  JsonApiServer(this.resource, this.resolver, this.links);

  Future<ServerResponse> handle(R rq) async {
    final jsonApiRequest = resolver(rq);
    if (jsonApiRequest == null || !resource.supports(jsonApiRequest.type)) {
      return ServerResponse(404);
    }
    return jsonApiRequest.perform(this);
  }

  Future<ServerResponse> fetchCollection(CollectionRequest<R> request) async {
    final collection = await resource.fetchCollection(request);
    final pagination = PaginationLinks.fromMap(collection.page.asMap.map(
        (name, page) => MapEntry(
            name, links.collection(request.type, params: page?.parameters))));
    return ServerResponse.ok(CollectionDocument(
        collection.elements.map(_addLinks),
        self:
            links.collection(request.type, params: collection.page?.parameters),
        pagination: pagination));
  }

  Future<ServerResponse> fetchResource(ResourceRequest<R> request) async {
    final res = await resource.fetchResource(request);
    return ServerResponse.ok(ResourceDocument(_addLinks(res)));
  }

  Future<ServerResponse> fetchRelated(RelatedRequest<R> request) async {
    final res = await resource.fetchRelated(request);
    return ServerResponse.ok(ResourceDocument(res));
  }

  Future<ServerResponse> fetchRelationship(RelationshipRequest rq) async {
    final rel = await resource.fetchRelationship(rq);
    print(RelationshipDocument(rel).toJson());
    return ServerResponse.ok(RelationshipDocument(rel));
  }

  Resource _addLinks(Resource r) => r.replace(
      self: links.resource(r.type, r.id),
      relationships: r.relationships.map((name, _) => MapEntry(
          name,
          _.replace(
              related: links.related(r.type, r.id, name),
              self: links.relationship(r.type, r.id, name)))));
}

class Collection<T> {
  Iterable<T> elements;
  final Page page;

  Collection(this.elements, {this.page});
}

abstract class ResourceController<R> {
  bool supports(String type);

  Future<Collection<Resource>> fetchCollection(CollectionRequest<R> request);

  Future<Resource> fetchResource(ResourceRequest<R> request);

  Future<Resource> fetchRelated(RelatedRequest<R> request);

  Future<Relationship> fetchRelationship(RelationshipRequest request);
}

/// An object which can be encoded as URI query parameters
abstract class QueryParameters {
  Map<String, String> get parameters;
}

/// Pagination
/// https://jsonapi.org/format/#fetching-pagination
abstract class Page implements QueryParameters {
  /// Next page or null
  Page get next;

  /// Previous page or null
  Page get prev;

  /// First page or null
  Page get first;

  /// Last page or null
  Page get last;

  Map<String, Page> get asMap =>
      {'first': first, 'last': last, 'prev': prev, 'next': next};
}

class NumberedPage extends Page {
  final int number;
  final int total;

  NumberedPage(this.number, {this.total});

  Map<String, String> get parameters {
    if (number > 1) {
      return {'page[number]': number.toString()};
    }
    return {};
  }

  Page get first => NumberedPage(1, total: total);

  Page get last => NumberedPage(total, total: total);

  Page get next => NumberedPage(min(number + 1, total), total: total);

  Page get prev => NumberedPage(max(number - 1, 1), total: total);

  NumberedPage.fromQueryParameters(Map<String, String> queryParameters,
      {int total})
      : this(int.parse(queryParameters['page[number]'] ?? '1'), total: total);
}
