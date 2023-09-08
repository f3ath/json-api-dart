import 'package:http_interop/http_interop.dart';

class MockHandler implements Handler {
  late Request request;
  late Response response;

  @override
  Future<Response> handle(Request request) async {
    this.request = request;
    return response;
  }
}
