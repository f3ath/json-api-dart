import 'dart:io';

import "package:stream_channel/stream_channel.dart";

import '../example/cars_server.dart';

hybridMain(StreamChannel channel, Object message) async {
  final port = 8080;
  final server = createServer();
  await server.start(InternetAddress.loopbackIPv4, port);
  channel.sink.add(port);
}
