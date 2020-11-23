import 'package:json_api/http.dart';
import 'package:json_api/src/server/error_converter.dart';
import 'package:json_api/src/server/response.dart';

/// Calls the wrapped handler within a try-catch block.
/// When an [HttpResponse] is thrown, returns it.
/// When any other error is thrown, ties to convert it using [ErrorConverter],
/// or returns an HTTP 500.
class TryCatchHttpHandler implements HttpHandler {
  TryCatchHttpHandler(this.httpHandler, this.errorConverter);

  final HttpHandler httpHandler;
  final ErrorConverter errorConverter;

  /// Handles the request by calling the appropriate method of the controller
  @override
  Future<HttpResponse> call(HttpRequest request) async {
    try {
      return await httpHandler(request);
    } on HttpResponse catch (response) {
      return response;
    } catch (error) {
      return (await errorConverter.convert(error)) ??
          Response.internalServerError();
    }
  }
}
