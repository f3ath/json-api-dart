import 'package:http_interop/http_interop.dart';
import 'package:json_api/document.dart';

/// A response to a relationship fetch request.
class RelationshipFetched<R extends Relationship> {
  RelationshipFetched(this.httpResponse, this.relationship);

  static RelationshipFetched<ToMany> many(Response httpResponse, Map json) =>
      RelationshipFetched(httpResponse, InboundDocument(json).asToMany())
        ..included.addAll(InboundDocument(json).included());

  static RelationshipFetched<ToOne> one(Response httpResponse, Map json) =>
      RelationshipFetched(httpResponse, InboundDocument(json).asToOne())
        ..included.addAll(InboundDocument(json).included());

  final Response httpResponse;
  final R relationship;
  final included = <Resource>[];
}
