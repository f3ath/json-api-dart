import 'dart:async';
import 'package:json_api/document.dart';
import 'package:json_api/src/server/routing.dart';


class DocumentController implements CRUDController<Document> {
  final Routing routing;

  DocumentController(this.routing, this.resource);


  Iterable<Resource> _addLinks(Iterable<Resource> rs) =>
      rs.map((r) => r.replace(
          self: routing.resourceLink(r.type, r.id),
          relationships: r.relationships.map((name, _) => MapEntry(
              name,
              _.replace(
                  related: routing.relatedLink(r.type, r.id, name),
                  self: routing.relationshipLink(r.type, r.id, name))))));
}
