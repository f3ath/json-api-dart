import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';

abstract class JsonApiRequest<T> {
  String get method;

  String get body;

  Map<String, String> get headers;

  Uri uri(TargetMapper<Uri> urls);

  T response(HttpResponse response);
}
