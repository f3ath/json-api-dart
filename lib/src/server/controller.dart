import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';

abstract class JsonApiController<T> {
  T fetchCollection(HttpRequest request, CollectionTarget target);

  T createResource(HttpRequest request, CollectionTarget target);

  T fetchResource(HttpRequest request, ResourceTarget target);
}
