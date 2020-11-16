import 'package:json_api/http.dart';
import 'package:json_api/src/client/request/internal/simple_request.dart';
import 'package:json_api/src/client/response/resource_response.dart';
import 'package:json_api/routing.dart';

class FetchRelatedResource extends SimpleRequest<ResourceResponse> {
  FetchRelatedResource(String type, String id, String relationship)
      : this.build(RelatedTarget(type, id, relationship));

  FetchRelatedResource.build(this.target) : super('get');

  @override
  final RelatedTarget target;

  @override
  ResourceResponse response(HttpResponse response) =>
      ResourceResponse.decode(response);
}
