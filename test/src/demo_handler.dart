import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/handler.dart';
import 'package:json_api/src/server/_internal/in_memory_repo.dart';
import 'package:json_api/src/server/_internal/repo.dart';
import 'package:json_api/src/server/_internal/repository_controller.dart';
import 'package:json_api/src/server/method_not_allowed.dart';
import 'package:json_api/src/server/unmatched_target.dart';

import 'sequential_numbers.dart';

class DemoHandler implements AsyncHandler<HttpRequest, HttpResponse> {
  DemoHandler(
      {void Function(HttpRequest request)? logRequest,
      void Function(HttpResponse response)? logResponse}) {
    final repo = InMemoryRepo(['users', 'posts', 'comments']);

    _handler = LoggingHandler(
        _Cors(TryCatchHandler(
            Router(RepositoryController(repo, sequentialNumbers),
                StandardUriDesign.matchTarget),
            _onError)),
        onResponse: logResponse,
        onRequest: logRequest);
  }

  late AsyncHandler<HttpRequest, HttpResponse> _handler;

  @override
  Future<HttpResponse> call(HttpRequest request) => _handler.call(request);

  static Future<JsonApiResponse> _onError(dynamic error) async {
    if (error is MethodNotAllowed) {
      return JsonApiResponse.methodNotAllowed();
    }
    if (error is UnmatchedTarget) {
      return JsonApiResponse.badRequest();
    }
    if (error is CollectionNotFound) {
      return JsonApiResponse.notFound(
          OutboundErrorDocument([ErrorObject(title: 'CollectionNotFound')]));
    }
    if (error is ResourceNotFound) {
      return JsonApiResponse.notFound(
          OutboundErrorDocument([ErrorObject(title: 'ResourceNotFound')]));
    }
    if (error is RelationshipNotFound) {
      return JsonApiResponse.notFound(
          OutboundErrorDocument([ErrorObject(title: 'RelationshipNotFound')]));
    }
    return JsonApiResponse(500,
        document: OutboundErrorDocument([
          ErrorObject(
              title: 'Error: ${error.runtimeType}', detail: error.toString())
        ]));
  }
}

/// Adds CORS headers and handles pre-flight requests.
class _Cors implements AsyncHandler<HttpRequest, HttpResponse> {
  _Cors(this._handler);

  final AsyncHandler<HttpRequest, HttpResponse> _handler;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final headers = {
      'Access-Control-Allow-Origin': request.headers['origin'] ?? '*',
      'Access-Control-Expose-Headers': 'Location',
    };

    if (request.isOptions) {
      const methods = ['POST', 'GET', 'DELETE', 'PATCH', 'OPTIONS'];
      return HttpResponse(204)
        ..headers.addAll({
          ...headers,
          'Access-Control-Allow-Methods':
              // TODO: Chrome works only with uppercase, but Firefox - only without. WTF?
              request.headers['Access-Control-Request-Method']?.toUpperCase() ??
                  methods.join(', '),
          'Access-Control-Allow-Headers':
              request.headers['Access-Control-Request-Headers'] ?? '*',
        });
    }
    return await _handler(request)
      ..headers.addAll(headers);
  }
}
