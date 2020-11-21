import 'package:json_api/src/_demo/demo_server.dart';
import 'package:json_api/src/_demo/in_memory_repo.dart';
import 'package:stream_channel/stream_channel.dart';

void hybridMain(StreamChannel channel, Object message) async {
  final demo = DemoServer(InMemoryRepo(['users', 'posts', 'comments']));
  await demo.start();
  channel.sink.add(demo.uri.toString());
}
