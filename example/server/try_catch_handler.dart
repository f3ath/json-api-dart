import 'package:json_api/http.dart';

class TryCatchHandler implements HttpHandler {
  TryCatchHandler(this._inner, {this.onError = sendInternalServerError});

  final HttpHandler _inner;
  final Future<HttpResponse> Function(dynamic error) onError;

  static Future<HttpResponse> sendInternalServerError(dynamic e) async =>
      HttpResponse(500);

  @override
  Future<HttpResponse> handle(HttpRequest request) async {
    try {
      return await _inner.handle(request);
    } on HttpResponse catch (response) {
      return response;
    } catch (error) {
      return await onError(error);
    }
  }
}
