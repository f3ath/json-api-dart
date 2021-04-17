import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'in_memory_repo.dart';
import 'repository.dart';
import 'repository_controller.dart';
import 'try_catch_handler.dart';

class DemoHandler extends LoggingHandler {
  DemoHandler({
    Iterable<String> types = const ['users', 'posts', 'comments'],
    Function(HttpRequest request)? onRequest,
    Function(HttpResponse response)? onResponse,
  }) : super(
            TryCatchHandler(
                Router(RepositoryController(InMemoryRepo(types), _id),
                    StandardUriDesign.matchTarget),
                onError: _onError),
            onRequest: onRequest,
            onResponse: onResponse);

  static Future<HttpResponse> _onError(dynamic error) async {
    if (error is MethodNotAllowed) {
      return Response.methodNotAllowed();
    }
    if (error is UnmatchedTarget) {
      return Response.badRequest();
    }
    if (error is CollectionNotFound) {
      return Response.notFound(
          OutboundErrorDocument([ErrorObject(title: 'CollectionNotFound')]));
    }
    if (error is ResourceNotFound) {
      return Response.notFound(
          OutboundErrorDocument([ErrorObject(title: 'ResourceNotFound')]));
    }
    if (error is RelationshipNotFound) {
      return Response.notFound(
          OutboundErrorDocument([ErrorObject(title: 'RelationshipNotFound')]));
    }
    return Response(500,
        document: OutboundErrorDocument([
          ErrorObject(
              title: 'Error: ${error.runtimeType}', detail: error.toString())
        ]));
  }
}

int _counter = 0;

String _id() => (_counter++).toString();
