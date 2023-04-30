import 'package:http_interop/http_interop.dart';

class MockHandler implements HttpHandler {
  late HttpRequest request;
  late HttpResponse response;

  @override
  Future<HttpResponse> handle(HttpRequest request) async {
    this.request = request;
    return response;
  }
}
