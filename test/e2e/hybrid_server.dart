// @dart=2.10
import 'package:stream_channel/stream_channel.dart';

import '../src/demo_handler.dart';
import '../src/json_api_server.dart';

void hybridMain(StreamChannel channel, Object message) async {
  final server = JsonApiServer(DemoHandler(), port: 8000);
  await server.start();
  channel.sink.add(server.uri.toString());
}
