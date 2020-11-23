import 'package:json_api/src/http/http_response.dart';
import 'package:json_api/src/server/_internal/repo.dart';
import 'package:json_api/src/server/error_converter.dart';
import 'package:json_api/src/server/response.dart';

class RepositoryErrorConverter implements ErrorConverter {
  @override
  Future<HttpResponse /*?*/ > convert(Object error) async {
    if (error is CollectionNotFound) {
      return Response.notFound();
    }
    return null;
  }
}
