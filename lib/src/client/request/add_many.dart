import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/request/internal/payload_request.dart';
import 'package:json_api/src/client/response/relationship_response.dart';

class AddMany extends PayloadRequest<RelationshipResponse<Many>> {
  AddMany(this.target, Many many) : super('post', many);

  AddMany.build(
      String type, String id, String relationship, List<Identifier> identifiers)
      : this(RelationshipTarget(type, id, relationship), Many(identifiers));

  @override
  final RelationshipTarget target;

  @override
  RelationshipResponse<Many> response(HttpResponse response) =>
      RelationshipResponse.decode<Many>(response);
}
