import 'package:json_api/server.dart';
import 'package:json_api/src/server/_internal/cors_http_handler.dart';
import 'package:json_api/src/server/_internal/in_memory_repo.dart';
import 'package:json_api/src/server/_internal/repository_controller.dart';
import 'package:json_api/src/server/_internal/repository_error_converter.dart';
import 'package:json_api/src/server/response_encoder.dart';
import 'package:json_api_server/json_api_server.dart';
import 'package:uuid/uuid.dart';

JsonApiServer demoServer({int port = 8080}) {
  final repo = InMemoryRepo(['users', 'posts', 'comments']);
  final controller = RepositoryController(repo, Uuid().v4);
  final errorConverter = ChainErrorConverter([
    RepositoryErrorConverter(),
    RoutingErrorConverter(),
  ], () async => JsonApiResponse.internalServerError());
  final handler = CorsHttpHandler(JsonApiResponseEncoder(
      TryCatchHandler(Router(controller), errorConverter)));

  return JsonApiServer(handler, port: port);
}
