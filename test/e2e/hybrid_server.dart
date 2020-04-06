import 'dart:io';

import 'package:json_api/server.dart';
import 'package:pedantic/pedantic.dart';
import 'package:stream_channel/stream_channel.dart';

void hybridMain(StreamChannel channel, Object port) async {
  final repo = InMemoryRepository({'writers': {}, 'books': {}});
  final jsonApiServer = JsonApiServer(RepositoryController(repo));
  final serverHandler = DartServer(jsonApiServer);
  final server = await HttpServer.bind('localhost', port);
  unawaited(server.forEach(serverHandler));
  channel.sink.add('ready');
}