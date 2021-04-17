import 'package:stream_channel/stream_channel.dart';

import '../../example/server/demo_handler.dart';
import '../../example/server/json_api_server.dart';

void hybridMain(StreamChannel channel, Object message) async {
  final host = 'localhost';
  final port = 8000;
  final server = JsonApiServer(DemoHandler(), host: host, port: port);
  await server.start();
  channel.sink.add('http://$host:$port');
}
