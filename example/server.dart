import 'dart:io';

import 'package:json_api/http.dart';
import 'package:json_api/src/_demo/demo_server.dart';
import 'package:json_api/src/_demo/in_memory_repo.dart';

Future<void> main() async {
  final demo = DemoServer(InMemoryRepo(['users', 'posts', 'comments']),
      logger: CallbackHttpLogger(onRequest: (r) {
        print('${r.method} ${r.uri}\n${r.headers}\n${r.body}\n\n');
      }, onResponse: (r) {
        print('${r.statusCode}\n${r.headers}\n${r.body}\n\n');
      }));
  await demo.start();
  ProcessSignal.sigint.watch().listen((event) async {
    await demo.stop();
    exit(0);
  });
}
