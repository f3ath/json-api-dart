import 'package:json_api/http.dart';

class TestHttpHandler implements HttpHandler {
  final requestLog = <HttpRequest>[];
  HttpResponse nextResponse;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    requestLog.add(request);
    return nextResponse;
  }
}
