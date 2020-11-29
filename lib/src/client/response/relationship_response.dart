import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/collection.dart';

/// A response to a relationship request.
class RelationshipResponse<T extends Relationship> {
  RelationshipResponse(this.http, this.relationship,
      {Iterable<Resource> included = const []}) {
    this.included.addAll(included);
  }

  static RelationshipResponse<ToMany> decodeMany(HttpResponse response) =>
      decode<ToMany>(response);

  static RelationshipResponse<ToOne> decodeOne(HttpResponse response) =>
      decode<ToOne>(response);

  static RelationshipResponse<T> decode<T extends Relationship>(
      HttpResponse response) {
    final doc = InboundDocument.decode(response.body);
    final rel = doc.dataAsRelationship();
    if (rel is T) {
      return RelationshipResponse(response, rel, included: doc.included);
    }
    throw FormatException();
  }

  /// Original HTTP response
  final HttpResponse http;
  final T relationship;

  /// Included resources
  final included = ResourceCollection();
}
