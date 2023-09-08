import 'package:http_interop/http_interop.dart' as http;
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';

import '../example/server/in_memory_repo.dart';
import '../example/server/repository_controller.dart';

class TestHandler extends http.LoggingHandler {
  TestHandler(
      {Iterable<String> types = const ['users', 'posts', 'comments'],
      Function(http.Request request)? onRequest,
      Function(http.Response response)? onResponse,
      Future<http.Response> Function(dynamic, StackTrace)? onError})
      : super(
            TryCatchHandler(
                ControllerRouter(RepositoryController(InMemoryRepo(types), _id),
                    StandardUriDesign.matchTarget),
                onError: ErrorConverter(
                    onError: onError ??
                        (err, trace) {
                          print(trace);
                          throw err;
                        })),
            onRequest: onRequest,
            onResponse: onResponse);
}

int _counter = 0;

String _id() => (_counter++).toString();
