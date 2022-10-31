import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';

import '../example/server/in_memory_repo.dart';
import '../example/server/repository_controller.dart';

class TestHandler extends LoggingHandler {
  TestHandler(
      {Iterable<String> types = const ['users', 'posts', 'comments'],
      Function(HttpRequest request)? onRequest,
      Function(HttpResponse response)? onResponse,
      Future<HttpResponse> Function(dynamic, StackTrace)? onError})
      : super(
            TryCatchHandler(
                Router(RepositoryController(InMemoryRepo(types), _id),
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