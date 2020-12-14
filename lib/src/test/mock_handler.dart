import 'package:json_api/http.dart';

class MockHandler implements Handler<HttpRequest, HttpResponse> {
  late HttpRequest request;
  late HttpResponse response;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    this.request = request;
    return response;
  }
}
