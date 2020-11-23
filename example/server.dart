import 'dart:io';

import 'package:json_api/http.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/_internal/cors_handler.dart';
import 'package:json_api/src/server/_internal/demo_server.dart';
import 'package:json_api/src/server/_internal/in_memory_repo.dart';
import 'package:json_api/src/server/_internal/repository_controller.dart';
import 'package:json_api/src/server/_internal/repository_error_converter.dart';
import 'package:json_api/src/server/_internal/routing_http_handler.dart';
import 'package:json_api/src/server/chain_error_converter.dart';
import 'package:json_api/src/server/routing_error_handler.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  final logger = CallbackHttpLogger(onRequest: (r) {
    print('${r.method} ${r.uri}\n${r.headers}\n${r.body}\n\n');
  }, onResponse: (r) {
    print('${r.statusCode}\n${r.headers}\n${r.body}\n\n');
  });
  final logging = LoggingHttpHandler(
      CorsHandler(TryCatchHttpHandler(
        RoutingHttpHandler(RepositoryController(
            InMemoryRepo(['users', 'posts', 'comments']), Uuid().v4)),
        ChainErrorConverter(
            [RepositoryErrorConverter(), RoutingErrorHandler()]),
      )),
      logger);
  final demo = DemoServer(logging);

  await demo.start();
  ProcessSignal.sigint.watch().listen((event) async {
    await demo.stop();
    exit(0);
  });
}
