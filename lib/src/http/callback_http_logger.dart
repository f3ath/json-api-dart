import 'package:json_api/http.dart';

class CallbackHttpLogger implements HttpLogger {
  const CallbackHttpLogger(
      {_Consumer<HttpRequest> onRequest, _Consumer<HttpResponse> onResponse})
      : _onRequest = onRequest,
        _onResponse = onResponse;

  final _Consumer<HttpRequest> /*?*/ _onRequest;

  final _Consumer<HttpResponse> /*?*/ _onResponse;

  @override
  void onRequest(HttpRequest request) {
    _onRequest?.call(request);
  }

  @override
  void onResponse(HttpResponse response) {
    _onResponse?.call(response);
  }
}

typedef _Consumer<R> = void Function(R r);
