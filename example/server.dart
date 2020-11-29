// @dart=2.10
import 'dart:io' as io;

import '../test/src/demo_handler.dart';
import '../test/src/json_api_server.dart';

Future<void> main() async {
  final server = JsonApiServer(DemoHandler(
      logRequest: (rq) => print([
            '>> Request >>',
            '${rq.method.toUpperCase()} ${rq.uri}',
            'Headers: ${rq.headers}',
            'Body: ${rq.body}',
          ].join('\n') +
          '\n'),
      logResponse: (rs) => print([
            '<< Response <<',
            'Status: ${rs.statusCode}',
            'Headers: ${rs.headers}',
            'Body: ${rs.body}',
          ].join('\n') +
          '\n')));

  io.ProcessSignal.sigint.watch().listen((event) async {
    await server.stop();
    io.exit(0);
  });

  await server.start();
  print('Server is listening at ${server.uri}');
}
