import 'dart:convert';

import 'package:json_api/src/client/request/internal/simple_request.dart';
import 'package:json_api/src/http/media_type.dart';

abstract class PayloadRequest<T> extends SimpleRequest<T> {
  PayloadRequest(String method, Object payload)
      : body = jsonEncode(payload),
        super(method) {
    headers['content-type'] = MediaType.jsonApi;
  }

  @override
  final String body;
}
