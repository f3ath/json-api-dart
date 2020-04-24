import 'package:json_api/http.dart';

class TransformingHttpHandler implements HttpHandler {
  TransformingHttpHandler(this._handler,
      {HttpRequestTransformer requestTransformer,
      HttpResponseTransformer responseTransformer})
      : _requestTransformer = requestTransformer ?? _identity,
        _responseTransformer = responseTransformer ?? _identity;

  final HttpHandler _handler;
  final HttpRequestTransformer _requestTransformer;
  final HttpResponseTransformer _responseTransformer;

  @override
  Future<HttpResponse> call(HttpRequest request) async =>
      _responseTransformer(await _handler.call(_requestTransformer(request)));
}

typedef HttpRequestTransformer = HttpRequest Function(HttpRequest _);
typedef HttpResponseTransformer = HttpResponse Function(HttpResponse _);

T _identity<T>(T _) => _;
