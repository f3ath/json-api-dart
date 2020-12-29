// @dart=2.10
import 'package:stream_channel/stream_channel.dart';

import '../../demo/demo_handler.dart';
import '../../demo/json_api_server.dart';

void hybridMain(StreamChannel channel, Object message) async {
  final server = JsonApiServer(DemoHandler(), port: 8000);
  await server.start();
  channel.sink.add(server.uri.toString());
}
