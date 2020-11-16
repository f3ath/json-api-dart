import 'package:json_api/http.dart';

class PrintingLogger implements HttpLogger {
  const PrintingLogger();

  @override
  void onRequest(HttpRequest request) {
    // print('Rq: ${request.method} ${request.uri}\n${request.headers}');
  }

  @override
  void onResponse(HttpResponse response) {
    // print('Rs: ${response.statusCode}\n${response.headers}');
  }
}
