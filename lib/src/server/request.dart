import 'dart:async';
import 'dart:convert';
import 'dart:io';

enum HttpMethod { get, post, put, delete, patch }

abstract class JsonApiHttpRequest {
  HttpMethod get method;

  Uri get uri;

  Future<String> body();

  List<String> headers(String key);
}

class NativeHttpRequestAdapter implements JsonApiHttpRequest {
  final HttpRequest request;

  NativeHttpRequestAdapter(this.request);

  HttpMethod get method => {
        'get': HttpMethod.get,
        'post': HttpMethod.post,
        'delete': HttpMethod.delete,
        'put': HttpMethod.put,
        'patch': HttpMethod.patch,
      }[request.method.toLowerCase()];

  Uri get uri => request.uri;

  List<String> headers(String key) => request.headers[key];

  Future<String> body() => request.transform(utf8.decoder).join();
}
