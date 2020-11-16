import 'package:json_api/http.dart';
import 'package:json_api/src/client/request/internal/payload_request.dart';
import 'package:json_api/src/client/response/new_resource_response.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';

class CreateNewResource extends PayloadRequest<NewResourceResponse> {
  CreateNewResource(this.target, NewResource properties)
      : super('post', {'data': properties});

  CreateNewResource.build(String type,
      {Map<String, Object /*?*/ > attributes = const {},
      Map<String, Identifier> one = const {},
      Map<String, Iterable<Identifier>> many = const {},
      Map<String, Object /*?*/ > meta = const {}})
      : this(
            CollectionTarget(type),
            NewResource(type)
              ..attributes.addAll(attributes)
              ..relationships.addAll({
                ...one.map((key, value) => MapEntry(key, One(value))),
                ...many.map((key, value) => MapEntry(key, Many(value))),
              })
              ..meta.addAll(meta));

  @override
  final CollectionTarget target;

  @override
  NewResourceResponse response(HttpResponse response) =>
      NewResourceResponse.decode(response);
}
