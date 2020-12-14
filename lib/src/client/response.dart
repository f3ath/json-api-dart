import 'package:json_api/http.dart';

class Response {
  Response(this.http, this.json);

  /// HTTP response
  final HttpResponse http;

  /// Raw JSON response
  final Map? json;
}
