import 'package:json_api/http.dart';

class TestHttpHandler implements HttpHandler {
  final requestLog = <HttpRequest>[];
  HttpResponse response;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    requestLog.add(request);
    return response;
  }
}
