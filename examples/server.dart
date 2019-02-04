import 'dart:io';

import 'server/server.dart';

void main() async {
  final addr = InternetAddress.loopbackIPv4;
  final port = 8080;
  await createServer().start(addr, port);
  print('Listening on ${addr.host}:$port');
}
