import 'dart:io';

import '../test/test_server.dart';

void main() async {
  final s = TestServer();
  await s.start(InternetAddress.loopbackIPv4, 8080);
}