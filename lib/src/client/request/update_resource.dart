import 'package:json_api/http.dart';
import 'package:json_api/src/client/request/internal/payload_request.dart';
import 'package:json_api/src/client/response/resource_response.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';

class UpdateResource extends PayloadRequest<ResourceResponse> {
  UpdateResource(
    String type,
    String id, {
    Map<String, Object /*?*/ > attributes = const {},
    Map<String, Identifier> one = const {},
    Map<String, Iterable<Identifier>> many = const {},
    Map<String, Object /*?*/ > meta = const {},
  }) : this.build(
            ResourceTarget(type, id),
            Resource(type, id)
              ..attributes.addAll(attributes)
              ..relationships.addAll({
                ...one.map((key, value) => MapEntry(key, One(value))),
                ...many.map((key, value) => MapEntry(key, Many(value))),
              })
              ..meta.addAll(meta));

  UpdateResource.build(this.target, Resource resource)
      : super('patch', {'data': resource});

  @override
  final ResourceTarget target;

  /// Returns [ResourceResponse]
  @override
  ResourceResponse response(HttpResponse response) =>
      ResourceResponse.decode(response);
}
