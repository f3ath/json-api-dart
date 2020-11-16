import 'package:json_api/http.dart';
import 'package:json_api/src/client/request/internal/simple_request.dart';
import 'package:json_api/src/client/response/relationship_response.dart';
import 'package:json_api/routing.dart';

class FetchRelationship extends SimpleRequest<RelationshipResponse> {
  FetchRelationship(String type, String id, String relationship)
      : this.build(RelationshipTarget(type, id, relationship));

  FetchRelationship.build(this.target) : super('get');

  @override
  final RelationshipTarget target;

  @override
  RelationshipResponse response(HttpResponse response) =>
      RelationshipResponse.decode(response);
}
