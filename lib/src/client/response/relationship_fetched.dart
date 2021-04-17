import 'package:json_api/document.dart';
import 'package:json_api/http.dart';

/// A response to a relationship fetch request.
class RelationshipFetched<R extends Relationship> {
  RelationshipFetched(this.http, this.relationship);

  static RelationshipFetched<ToMany> many(HttpResponse http, Map json) =>
      RelationshipFetched(http, InboundDocument(json).asToMany())
        ..included.addAll(InboundDocument(json).included());

  static RelationshipFetched<ToOne> one(HttpResponse http, Map json) =>
      RelationshipFetched(http, InboundDocument(json).asToOne())
        ..included.addAll(InboundDocument(json).included());

  final HttpResponse http;
  final R relationship;
  final included = ResourceCollection();
}
