import 'package:http_interop/http_interop.dart';
import 'package:http_interop_middleware/http_interop_middleware.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';

import '../example/server/in_memory_repo.dart';
import '../example/server/repository_controller.dart';

Handler testHandler(
        {Iterable<String> types = const ['users', 'posts', 'comments'],
        Function(Request request)? onRequest,
        Function(Response response)? onResponse}) =>
    corsMiddleware.add(requestValidator).add(errorConverter()).call(
        router(RepositoryController(InMemoryRepo(types), _nextId),
            StandardUriDesign.matchTarget));

String _nextId() => (_counter++).toString();
int _counter = 0;
