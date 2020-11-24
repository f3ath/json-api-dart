import 'package:stream_channel/stream_channel.dart';

import '../src/demo_server.dart';

void hybridMain(StreamChannel channel, Object message) async {
  final server = demoServer(port: 8000);
  await server.start();
  channel.sink.add(server.uri.toString());
}
