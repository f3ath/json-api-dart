import 'dart:convert';
import 'dart:io';

import 'package:json_api_document/json_api_document.dart';

/// Run this server before trying out the example
void main() async {
  final port = 8888;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  final document = DataDocument.fromResource(
      Resource('example', '42', attributes: {'message': 'Hello world!'}),
      api: Api('1.0'));
  server.listen((_) {
    _.response.headers.contentType = ContentType.parse(Document.mediaType);
    _.response.headers.add('Access-Control-Allow-Origin', '*');
    _.response.write(json.encode(document));
    _.response.close();
  });
  print('Server is listening on http://localhost:8888');
  print('Press ^C to close');
}
