import 'package:http_interop/http_interop.dart';
import 'package:http_interop_middleware/http_interop_middleware.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';

import '../example/server/in_memory_repo.dart';
import '../example/server/repository_controller.dart';

Handler testHandler({
  Iterable<String> types = const ['users', 'posts', 'comments'],
  Function(Request request)? onRequest,
  Function(Response response)? onResponse,
  PayloadHandler? onPayload,
}) {
  final controller = RepositoryController(InMemoryRepo(types), _nextId);
  return [
    corsMiddleware,
    requestValidatorMiddleware,
    errorConverter(onError: (e, _) => throw e),
  ].combine().call(
    router(
      getTarget: (rq) => StandardUriDesign.pathOnly.target(rq.uri),
      getController: (_, _) => controller,
      beforeDispatch: onPayload,
    ),
  );
}

String _nextId() => (_counter++).toString();
int _counter = 0;
