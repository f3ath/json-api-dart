import 'dart:io';

import 'package:stream_channel/stream_channel.dart';

import '../../example/server.dart';

void hybridMain(StreamChannel channel, Object message) async {
  final port = 8080;
  await createServer(InternetAddress.loopbackIPv4, port);
  channel.sink.add(port);
}
