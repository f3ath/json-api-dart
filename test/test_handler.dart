import 'package:http_interop/http_interop.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';

import '../example/server/in_memory_repo.dart';
import '../example/server/repository_controller.dart';

Handler testHandler(
        {Iterable<String> types = const ['users', 'posts', 'comments'],
        Function(Request request)? onRequest,
        Function(Response response)? onResponse,
        Future<Response> Function(dynamic, StackTrace)? onError}) =>
    loggingMiddleware(
        corsMiddleware(tryCatchMiddleware(
            ControllerRouter(
                    RepositoryController(
                        InMemoryRepo(types), () => (_counter++).toString()),
                    StandardUriDesign.matchTarget)
                .handle,
            onError: ErrorConverter(
                    onError: onError ??
                        (err, trace) {
                          print(trace);
                          throw err;
                        })
                .call)),
        onRequest: onRequest,
        onResponse: onResponse);

int _counter = 0;
