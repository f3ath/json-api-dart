import 'package:json_api/http.dart';

class TryCatchHandler implements HttpHandler {
  TryCatchHandler(this.handler, {this.onError = sendInternalServerError});

  final HttpHandler handler;
  final Future<HttpResponse> Function(dynamic error) onError;

  static Future<HttpResponse> sendInternalServerError(dynamic e) async =>
      HttpResponse(500);

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    try {
      return await handler(request);
    } on HttpResponse catch (response) {
      return response;
    } catch (error) {
      return await onError(error);
    }
  }
}
