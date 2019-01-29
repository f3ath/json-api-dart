import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/routing.dart';

abstract class ResourceController {
  FutureOr<Collection<Resource>> fetchCollection(String type);
}

class Collection<T> {
  Iterable<T> elements;
  Page page;

  Collection(this.elements, {this.page});
}

class DocumentController implements CRUDController<Document> {
  final Routing routing;
  final ResourceController resource;

  DocumentController(this.routing, this.resource);

  @override
  FutureOr<Document> fetchCollection(CollectionOperation op) async {
    final c = await resource.fetchCollection(op.type);
    return CollectionDocument(_addLinks(c.elements).toList(),
        self: routing.collectionLink(op.type));
  }

  @override
  FutureOr<Document> fetchResource(ResourceOperation operation) => null;

  @override
  FutureOr<Document> fetchRelated(RelatedOperation operation) => null;

  @override
  FutureOr<Document> fetchRelationship(RelationshipOperation operation) => null;

  Iterable<Resource> _addLinks(Iterable<Resource> rs) =>
      rs.map((r) => r.replace(
          self: routing.resourceLink(r.type, r.id),
          relationships: r.relationships.map((name, _) => MapEntry(
              name,
              _.replace(
                  related: routing.relatedLink(r.type, r.id, name),
                  self: routing.relationshipLink(r.type, r.id, name))))));
}
