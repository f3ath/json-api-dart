import 'package:json_api/document.dart';
import 'package:json_api/http.dart';

/// A response to a relationship request.
class RelationshipUpdated<R extends Relationship> {
  RelationshipUpdated(this.http, this.relationship);

  static RelationshipUpdated<ToMany> many(HttpResponse http, Map? json) =>
      RelationshipUpdated(
          http, json == null ? null : InboundDocument(json).asToMany());

  static RelationshipUpdated<ToOne> one(HttpResponse http, Map? json) =>
      RelationshipUpdated(
          http, json == null ? null : InboundDocument(json).asToOne());

  final HttpResponse http;

  /// Updated relationship. Null if "204 No Content" is returned.
  final R? relationship;
}
