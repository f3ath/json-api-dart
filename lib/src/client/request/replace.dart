import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/request/internal/payload_request.dart';
import 'package:json_api/src/client/response/relationship_response.dart';

class Replace<R extends Relationship>
    extends PayloadRequest<RelationshipResponse<R>> {
  Replace(this.target, R data) : super('patch', data);

  Replace.build(String type, String id, String relationship, R data)
      : this(RelationshipTarget(type, id, relationship), data);

  @override
  final RelationshipTarget target;

  @override
  RelationshipResponse<R> response(HttpResponse response) =>
      RelationshipResponse.decode<R>(response);
}
