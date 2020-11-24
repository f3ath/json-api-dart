import 'package:json_api/handler.dart';
import 'package:json_api/src/server/_internal/repo.dart';
import 'package:json_api/src/server/json_api_response.dart';

class RepositoryErrorConverter
    implements Handler<Object, JsonApiResponse /*?*/ > {
  @override
  Future<JsonApiResponse /*?*/ > call(Object error) async {
    if (error is CollectionNotFound) {
      return JsonApiResponse.notFound();
    }
    return null;
  }
}
