import 'package:http_interop/http_interop.dart' as interop;
import 'package:json_api/document.dart';

/// A response to a relationship fetch request.
class RelationshipFetched<R extends Relationship> {
  RelationshipFetched(this.http, this.relationship);

  static RelationshipFetched<ToMany> many(interop.Response http, Map json) =>
      RelationshipFetched(http, InboundDocument(json).asToMany())
        ..included.addAll(InboundDocument(json).included());

  static RelationshipFetched<ToOne> one(interop.Response http, Map json) =>
      RelationshipFetched(http, InboundDocument(json).asToOne())
        ..included.addAll(InboundDocument(json).included());

  final interop.Response http;
  final R relationship;
  final included = <Resource>[];
}
