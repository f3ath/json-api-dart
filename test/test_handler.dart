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
    errorConverter().add(corsMiddleware).call(routingHandler(
        RepositoryController(
            InMemoryRepo(types), () => (_counter++).toString()),
        StandardUriDesign.matchTarget));

int _counter = 0;
