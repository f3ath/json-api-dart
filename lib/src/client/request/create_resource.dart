import 'package:json_api/http.dart';
import 'package:json_api/src/client/request/internal/payload_request.dart';
import 'package:json_api/src/client/response/resource_response.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';

class CreateResource extends PayloadRequest<ResourceResponse> {
  CreateResource(this.target, Resource resource)
      : super('post', {'data': resource});

  CreateResource.build(
    String type,
    String id, {
    Map<String, Object /*?*/ > attributes = const {},
    Map<String, Identifier> one = const {},
    Map<String, Iterable<Identifier>> many = const {},
    Map<String, Object /*?*/ > meta = const {},
  }) : this(
            CollectionTarget(type),
            Resource(type, id)
              ..attributes.addAll(attributes)
              ..relationships.addAll({
                ...one.map((k, v) => MapEntry(k, One(v))),
                ...many.map((k, v) => MapEntry(k, Many(v))),
              })
              ..meta.addAll(meta));

  @override
  final CollectionTarget target;

  @override
  ResourceResponse response(HttpResponse response) =>
      ResourceResponse.decode(response);
}
