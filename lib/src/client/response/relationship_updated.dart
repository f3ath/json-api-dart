import 'package:json_api/document.dart';
import 'package:json_api/src/client/response.dart';

/// A response to a relationship request.
class RelationshipUpdated<R extends Relationship> {
  RelationshipUpdated(this.rawResponse, this.relationship);

  static RelationshipUpdated<ToMany> many(Response response) {
    final json = response.document;
    return RelationshipUpdated(
        response, json == null ? null : InboundDocument(json).asToMany());
  }

  static RelationshipUpdated<ToOne> one(Response response) {
    final json = response.document;
    return RelationshipUpdated(
        response, json == null ? null : InboundDocument(json).asToOne());
  }

  /// The raw JSON:API response
  final Response rawResponse;

  /// Updated relationship. Null if "204 No Content" is returned.
  final R? relationship;
}
