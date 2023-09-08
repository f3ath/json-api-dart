import 'package:http_interop/http_interop.dart';
import 'package:json_api/document.dart';

/// A response to a relationship request.
class RelationshipUpdated<R extends Relationship> {
  RelationshipUpdated(this.httpResponse, this.relationship);

  static RelationshipUpdated<ToMany> many(Response httpResponse, Map? json) =>
      RelationshipUpdated(
          httpResponse, json == null ? null : InboundDocument(json).asToMany());

  static RelationshipUpdated<ToOne> one(Response httpResponse, Map? json) =>
      RelationshipUpdated(
          httpResponse, json == null ? null : InboundDocument(json).asToOne());

  final Response httpResponse;

  /// Updated relationship. Null if "204 No Content" is returned.
  final R? relationship;
}
