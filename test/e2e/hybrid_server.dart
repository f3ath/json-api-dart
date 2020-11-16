import 'package:stream_channel/stream_channel.dart';

import '../../example/demo/demo_server.dart';

void hybridMain(StreamChannel channel, Object initSql) async {
  final demo = DemoServer(initSql);
  await demo.start();
  channel.sink.add(demo.uri);
}
