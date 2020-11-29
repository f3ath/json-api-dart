import 'package:json_api/document.dart';
import 'package:json_api/handler.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/_internal/cors_http_handler.dart';
import 'package:json_api/src/server/_internal/in_memory_repo.dart';
import 'package:json_api/src/server/_internal/repo.dart';
import 'package:json_api/src/server/_internal/repository_controller.dart';
import 'package:json_api/src/server/method_not_allowed.dart';
import 'package:json_api/src/server/unmatched_target.dart';

class DemoHandler implements Handler<HttpRequest, HttpResponse> {
  DemoHandler(
      {void Function(HttpRequest request)? logRequest,
      void Function(HttpResponse response)? logResponse}) {
    final repo = InMemoryRepo(['users', 'posts', 'comments']);

    _handler = LoggingHandler(
        CorsHttpHandler(TryCatchHandler(
            Router(RepositoryController(repo, _nextId),
                RecommendedUrlDesign.pathOnly.match),
            _onError)),
        onResponse: logResponse,
        onRequest: logRequest);
  }

  late Handler<HttpRequest, HttpResponse> _handler;

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
    return JsonApiResponse.internalServerError(OutboundErrorDocument([
      ErrorObject(
          title: 'Error: ${error.runtimeType}', detail: error.toString())
    ]));
  }
}

int _id = 0;

String _nextId() => (_id++).toString();
