import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/_internal/in_memory_repo.dart';
import 'package:json_api/src/server/_internal/repository_controller.dart';
import 'package:json_api/src/server/_internal/repository_error_converter.dart';
import 'package:json_api/src/server/_internal/routing_http_handler.dart';
import 'package:json_api/src/server/chain_error_converter.dart';
import 'package:json_api/src/server/routing_error_handler.dart';
import 'package:uuid/uuid.dart';




HttpHandler initServer() => TryCatchHttpHandler(
    RoutingHttpHandler(RepositoryController(
        InMemoryRepo(['users', 'posts', 'comments']), Uuid().v4)),
    ChainErrorConverter([RepositoryErrorConverter(), RoutingErrorHandler()]));
