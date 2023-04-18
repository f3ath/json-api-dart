import 'package:http_interop/http_interop.dart' as interop;
import 'package:json_api/document.dart';

/// A response to a relationship request.
class RelationshipUpdated<R extends Relationship> {
  RelationshipUpdated(this.http, this.relationship);

  static RelationshipUpdated<ToMany> many(interop.Response http, Map? json) =>
      RelationshipUpdated(
          http, json == null ? null : InboundDocument(json).asToMany());

  static RelationshipUpdated<ToOne> one(interop.Response http, Map? json) =>
      RelationshipUpdated(
          http, json == null ? null : InboundDocument(json).asToOne());

  final interop.Response http;

  /// Updated relationship. Null if "204 No Content" is returned.
  final R? relationship;
}
