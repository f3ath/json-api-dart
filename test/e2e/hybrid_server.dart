import 'package:json_api/server.dart';
import 'package:json_api/src/server/_internal/cors_handler.dart';
import 'package:json_api/src/server/_internal/demo_server.dart';
import 'package:json_api/src/server/_internal/in_memory_repo.dart';
import 'package:json_api/src/server/_internal/repository_controller.dart';
import 'package:json_api/src/server/_internal/repository_error_converter.dart';
import 'package:json_api/src/server/_internal/routing_http_handler.dart';
import 'package:json_api/src/server/chain_error_converter.dart';
import 'package:json_api/src/server/routing_error_handler.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:uuid/uuid.dart';

void hybridMain(StreamChannel channel, Object message) async {
  final handler = CorsHandler(TryCatchHttpHandler(
    RoutingHttpHandler(RepositoryController(InMemoryRepo(['users', 'posts', 'comments']), Uuid().v4)),
    ChainErrorConverter([RepositoryErrorConverter(), RoutingErrorHandler()]),
  ));
  final demo =
      DemoServer(handler, port: 8000);
  await demo.start();
  channel.sink.add(demo.uri.toString());
}
