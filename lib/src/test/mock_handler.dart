import 'package:json_api/http.dart';

class MockHandler implements HttpHandler {
  HttpResponse /*?*/ response;
  HttpRequest /*?*/ request;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    this.request = request;
    return response;
  }
}
