import 'dart:io';

import 'package:json_api/handler.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/_internal/cors_http_handler.dart';
import 'package:json_api/src/server/_internal/in_memory_repo.dart';
import 'package:json_api/src/server/_internal/repository_controller.dart';
import 'package:json_api/src/server/_internal/repository_error_converter.dart';
import 'package:json_api/src/server/response_encoder.dart';
import 'package:json_api_server/json_api_server.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  final repo = InMemoryRepo(['users', 'posts', 'comments']);
  final controller = RepositoryController(repo, Uuid().v4);
  final errorConverter = ChainErrorConverter([
    RepositoryErrorConverter(),
    RoutingErrorConverter(),
  ], () async => JsonApiResponse.internalServerError());
  final handler = CorsHttpHandler(JsonApiResponseEncoder(
      TryCatchHandler(Router(controller), errorConverter)));
  final loggingHandler = LoggingHandler(
      handler,
      (rq) => print([
            '>> ${rq.method.toUpperCase()} ${rq.uri}',
            'Headers: ${rq.headers}',
            'Body: ${rq.body}',
          ].join('\n') +
          '\n'),
      (rs) => print([
            '<< ${rs.statusCode}',
            'Headers: ${rs.headers}',
            'Body: ${rs.body}',
          ].join('\n') +
          '\n'));
  final server = JsonApiServer(loggingHandler);

  ProcessSignal.sigint.watch().listen((event) async {
    await server.stop();
    exit(0);
  });

  await server.start();
  print('Server is listening at ${server.uri}');
}
