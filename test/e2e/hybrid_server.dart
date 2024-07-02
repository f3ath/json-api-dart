import 'package:stream_channel/stream_channel.dart';

import '../../example/server/json_api_server.dart';
import '../test_handler.dart';

void hybridMain(StreamChannel channel) async {
  const host = 'localhost';
  const port = 8888;
  final server = JsonApiServer(testHandler(onRequest: print, onResponse: print),
      host: host, port: port);
  await server.start();
  channel.sink.add('http://$host:$port');
}
