import 'package:json_api/src/_testing/demo_handler.dart';
import 'package:json_api/src/_testing/json_api_server.dart';
import 'package:stream_channel/stream_channel.dart';

void hybridMain(StreamChannel channel, Object message) async {
  final host = 'localhost';
  final port = 8000;
  final server = JsonApiServer(DemoHandler(), host: host, port: port);
  await server.start();
  channel.sink.add('http://$host:$port');
}
