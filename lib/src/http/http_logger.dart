import 'package:json_api/http.dart';

abstract class HttpLogger {
  void onRequest(HttpRequest /*!*/ request);

  void onResponse(HttpResponse /*!*/ response);
}
