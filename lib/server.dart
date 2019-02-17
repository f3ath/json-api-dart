import 'dart:convert';
import 'dart:math';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/routing.dart';

export 'package:json_api/src/server/request.dart';
export 'package:json_api/src/server/routing.dart';


class JsonApiServer implements JsonApiController {
  final ResourceController resource;
  final Routing routing;

  JsonApiServer(this.resource, this.routing);

  Future<ServerResponse> handle(String method, Uri uri, String body) async {
    final jsonApiRequest = await routing.resolve(method, uri, body);
    if (jsonApiRequest == null || !resource.supports(jsonApiRequest.type)) {
      return ServerResponse(404);
    }
    return jsonApiRequest.fulfill(this);
  }

  Future<ServerResponse> fetchCollection(CollectionRequest rq) async {
    final collection =
        await resource.fetchCollection(rq.type, rq.queryParameters);

    final pagination = PaginationLinks.fromMap(collection.page
        .mapPages((_) => routing.collection(rq.type, params: _?.parameters)));

    return ServerResponse.ok(CollectionDocument(
        collection.elements.map(_addResourceLinks),
        self: routing.collection(rq.type, params: collection.page?.parameters),
        pagination: pagination));
  }

  Future<ServerResponse> fetchResource(ResourceRequest rq) async {
    final res = await _resource(rq.identifier);
    return ServerResponse.ok(
        ResourceDocument(res == null ? null : _addResourceLinks(res)));
  }

  Future<ServerResponse> fetchRelated(RelatedRequest rq) async {
    final res = await _resource(rq.identifier);
    final rel = res.relationships[rq.name];
    if (rel is ToOne) {
      return ServerResponse.ok(
          ResourceDocument(_addResourceLinks(await _resource(rel.identifier))));
    }

    if (rel is ToMany) {
      final list = await resource
          .fetchResources(rel.identifiers)
          .map(_addResourceLinks)
          .toList();

      return ServerResponse.ok(CollectionDocument(list,
          self: routing.related(rq.type, rq.id, rq.name)));
    }

    throw StateError('Unknown relationship type ${rel.runtimeType}');
  }

  Future<Resource> _resource(Identifier id) =>
      resource.fetchResources([id]).first;

  Future<ServerResponse> fetchRelationship(RelationshipRequest rq) async {
    final res = await _resource(rq.identifier);
    final rel = res.relationships[rq.name];
    return ServerResponse.ok(
        _addRelationshipLinks(rel, rq.type, rq.id, rq.name));
  }

  Future<ServerResponse> createResource(CollectionRequest rq) async {
    final doc = ResourceDocument.fromJson(json.decode(rq.body));
    await resource.createResource(rq.type, doc.resource);
    return ServerResponse(204);
  }

  Future<ServerResponse> addRelationship(RelationshipRequest rq) async {
    final rel = Relationship.fromJson(json.decode(rq.body));
    if (rel is ToMany) {
      await resource.mergeToMany(rq.identifier, rq.name, rel);
      final res = await _resource(rq.identifier);
      return ServerResponse.ok(_addRelationshipLinks(
          res.relationships[rq.name], rq.type, rq.id, rq.name));
    }
    // TODO: Return a meaningful response
    return null;
  }

  Resource _addResourceLinks(Resource r) => r.replace(
      self: routing.resource(r.type, r.id),
      relationships: r.relationships.map((name, _) =>
          MapEntry(name, _addRelationshipLinks(_, r.type, r.id, name))));

  Relationship _addRelationshipLinks(
          Relationship r, String type, String id, String name) =>
      r.replace(
          related: routing.related(type, id, name),
          self: routing.relationship(type, id, name));
}

class Collection<T> {
  Iterable<T> elements;
  final Page page;

  Collection(this.elements, {this.page});
}

abstract class ResourceController {
  bool supports(String type);

  Future<Collection<Resource>> fetchCollection(
      String type, Map<String, String> queryParameters);

  Stream<Resource> fetchResources(Iterable<Identifier> ids);

  Future createResource(String type, Resource resource);

  /// Add all ids in [rel] to the relationship [name] of the resource identified by [id].
  /// This implies that the relationship is a [ToMany] one.
  Future mergeToMany(Identifier id, String name, ToMany rel);
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

  Map<String, T> mapPages<T>(T f(Page p)) =>
      asMap.map((name, page) => MapEntry(name, f(page)));

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
