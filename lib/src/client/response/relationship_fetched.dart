import 'package:json_api/document.dart';
import 'package:json_api/src/client/response.dart';

/// A response to a relationship fetch request.
class RelationshipFetched<R extends Relationship> {
  RelationshipFetched(this.rawResponse, this.relationship);

  static RelationshipFetched<ToMany> many(Response response) {
    final document = InboundDocument(response.document ??
        (throw FormatException('The document must not be empty')));
    return RelationshipFetched(response, document.asToMany())
      ..included.addAll(document.included());
  }

  static RelationshipFetched<ToOne> one(Response response) {
    final document = InboundDocument(response.document ??
        (throw FormatException('The document must not be empty')));
    return RelationshipFetched(response, document.asToOne())
      ..included.addAll(document.included());
  }

  /// The raw JSON:API response
  final Response rawResponse;

  final R relationship;
  final included = <Resource>[];
}
