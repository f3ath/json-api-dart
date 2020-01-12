import 'package:json_api/server.dart';
import 'package:json_api/src/server/http_handler.dart';
import 'package:json_api/url_design.dart';
import 'package:shelf/shelf_io.dart';
import 'package:uuid/uuid.dart';

import 'crud_controller.dart';
import 'shelf_request_response_converter.dart';

/// This example shows how to build a simple CRUD server on top of Dart Shelf
void main() async {
  final host = 'localhost';
  final port = 8080;
  final baseUri = Uri(scheme: 'http', host: host, port: port);
  final jsonApiHandler = createHttpHandler(ShelfRequestResponseConverter(),
      CRUDController(Uuid().v4), PathBasedUrlDesign(baseUri));

  await serve(jsonApiHandler, host, port);
  print('Serving at $baseUri');
}
