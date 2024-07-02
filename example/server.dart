import 'dart:io';

import 'package:http_interop/http_interop.dart' as interop;
import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:uuid/uuid.dart';

import 'server/in_memory_repo.dart';
import 'server/json_api_server.dart';
import 'server/repository.dart';
import 'server/repository_controller.dart';

Future<void> main() async {
  final host = 'localhost';
  final port = 8080;
  final repo = InMemoryRepo(['colors']);
  await initRepo(repo);
  final controller = RepositoryController(repo, Uuid().v4);
  interop.Handler handler =
      ControllerRouter(controller, StandardUriDesign.matchTarget).handle;

  handler = tryCatchMiddleware(handler,
      onError: ErrorConverter(onError: (e, stack) async {
        stderr.writeln(e);
        stderr.writeln(stack);
        return response(500,
            document: OutboundErrorDocument(
                [ErrorObject(title: 'Internal Server Error')]));
      }).call);

  handler = loggingMiddleware(handler,
      onRequest: (r) => print('${r.method} ${r.uri}'),
      onResponse: (r) => print('${r.statusCode}'));
  final server = JsonApiServer(handler, host: host, port: port);

  ProcessSignal.sigint.watch().listen((event) async {
    await server.stop();
    exit(0);
  });

  await server.start();

  print('The server is listening at $host:$port.');
}

Future initRepo(Repository repo) async {
  final models = {
    {'name': 'Salmon', 'r': 250, 'g': 128, 'b': 114},
    {'name': 'Pink', 'r': 255, 'g': 192, 'b': 203},
    {'name': 'Lime', 'r': 0, 'g': 255, 'b': 0},
    {'name': 'Peru', 'r': 205, 'g': 133, 'b': 63},
  }.map((color) => Model(Uuid().v4())
    ..attributes['name'] = color['name']
    ..attributes['red'] = color['r']
    ..attributes['green'] = color['g']
    ..attributes['blue'] = color['b']);
  for (final model in models) {
    await repo.persist('colors', model);
  }
}
