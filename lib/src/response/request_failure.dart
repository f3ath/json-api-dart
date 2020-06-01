import 'dart:convert';

import 'package:json_api/json_api.dart';
import 'package:json_api/src/document/error_object.dart';
import 'package:json_api_common/http.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class RequestFailure {
  RequestFailure(this.http, {Iterable<ErrorObject> errors = const []})
      : errors = List.unmodifiable(errors ?? const []);

  static RequestFailure decode(HttpResponse http) {
    if (http.body.isEmpty ||
        http.headers['content-type'] != ContentType.jsonApi) {
      return RequestFailure(http);
    }

    return RequestFailure(http,
        errors: Just(http.body)
            .filter((_) => _.isNotEmpty)
            .map(jsonDecode)
            .cast<Map>()
            .flatMap((_) => Maybe(_['errors']))
            .cast<List>()
            .map((_) => _.map(ErrorObject.fromJson))
            .or([]));
  }

  final List<ErrorObject> errors;

  final HttpResponse http;
}
