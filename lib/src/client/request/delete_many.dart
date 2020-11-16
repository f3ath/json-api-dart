import 'package:json_api/http.dart';
import 'package:json_api/src/client/request/internal/payload_request.dart';
import 'package:json_api/src/client/response/relationship_response.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';

class DeleteMany extends PayloadRequest<RelationshipResponse<Many>> {
  DeleteMany(this.target, Many many) : super('delete', many);

  DeleteMany.build(
      String type, String id, String relationship, List<Identifier> identifiers)
      : this(RelationshipTarget(type, id, relationship), Many(identifiers));

  @override
  final RelationshipTarget target;

  @override
  RelationshipResponse<Many> response(HttpResponse response) =>
      RelationshipResponse.decode<Many>(response);
}
