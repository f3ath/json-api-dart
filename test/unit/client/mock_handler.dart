import 'package:http_interop/http_interop.dart';

class MockHandler {
  late Request request;
  late Response response;

  Future<Response> handle(Request request) async {
    this.request = request;
    return response;
  }
}
