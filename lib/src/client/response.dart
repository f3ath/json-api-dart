import 'package:json_api/http.dart' as h;

class Response {
  Response(this.http, this.json);

  /// HTTP response
  final h.HttpResponse http;

  /// Raw JSON response
  final Map? json;
}
