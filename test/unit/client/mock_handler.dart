import 'package:http_interop/http_interop.dart' as interop;

class MockHandler implements interop.Handler {
  late interop.Request request;
  late interop.Response response;

  @override
  Future<interop.Response> handle(interop.Request request) async {
    this.request = request;
    return response;
  }
}
