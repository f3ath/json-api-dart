import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/parser.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/contracts/controller.dart';
import 'package:json_api/src/server/contracts/document_builder.dart';
import 'package:json_api/src/server/contracts/router.dart';
import 'package:json_api/src/server/standard_document_builder.dart';
import 'package:json_api/src/server/request_target.dart';

part 'server_requests.dart';

part 'server_routes.dart';

class JsonApiServer {
  final Router router;
  final JsonApiController controller;

  JsonApiServer(this.router, this.controller);

  Future<void> process(HttpRequest httpRequest) async {
    const factory = _JsonApiRouteFactory();
    final route = await router.getRoute(httpRequest.requestedUri, factory);
    if (route == null) {
      httpRequest.response.statusCode = 404;
      return httpRequest.response.close();
    }
    final request = route.createRequest(httpRequest);
    final body = await httpRequest.transform(utf8.decoder).join();
    request.uri = httpRequest.requestedUri;
    if (body.isNotEmpty) request.setBody(json.decode(body));
    request.docBuilder = StandardDocumentBuilder(router);
    request.response = httpRequest.response;
    return request.call(controller);
  }
}
