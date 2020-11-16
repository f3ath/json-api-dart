import 'package:json_api/http.dart';
import 'package:json_api/src/client/request/internal/simple_request.dart';
import 'package:json_api/src/client/response/resource_response.dart';
import 'package:json_api/routing.dart';

class FetchResource extends SimpleRequest<ResourceResponse> {
  FetchResource(this.target) : super('get');

  FetchResource.build(String type, String id) : this(ResourceTarget(type, id));

  @override
  final ResourceTarget target;

  @override
  ResourceResponse response(HttpResponse response) =>
      ResourceResponse.decode(response);
}
