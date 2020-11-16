import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/method_not_allowed.dart';
import 'package:json_api/src/server/router.dart';

class JsonApiHandler implements HttpHandler {
  JsonApiHandler(this.controller,
      {TargetMatcher matcher,
      UriFactory urlDesign,
      this.exposeInternalErrors = false})
      : router = Router(matcher ?? RecommendedUrlDesign.pathOnly);

  final JsonApiController<Future<HttpResponse>> controller;
  final Router router;
  final bool exposeInternalErrors;

  /// Handles the request by calling the appropriate method of the controller
  @override
  Future<HttpResponse> call(HttpRequest request) async {
    try {
      return await router.route(request, controller);
    } on MethodNotAllowed {
      return HttpResponse(405);
    } catch (e) {
      var body = '';
      if (exposeInternalErrors) {
        final error = ErrorObject(
            title: 'Uncaught exception', detail: e.toString(), status: '500');
        error.meta['runtimeType'] = e.runtimeType.toString();
        if (e is Error) {
          error.meta['stackTrace'] = e.stackTrace.toString().trim().split('\n');
        }
        body = jsonEncode(OutboundErrorDocument([error]));
      }
      return HttpResponse(500, body: body);
    }
  }
}
