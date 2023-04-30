import 'package:http_interop/http_interop.dart';

/// An [HttpHandler] wrapper which calls the [wrapped] handler and does
/// the following:
/// - when an instance of [HttpResponse] is returned or thrown by the
///   [wrapped] handler, the response is returned
/// - when another error is thrown by the [wrapped] handler and
///   the [onError] callback is set, the error will be converted to a response
/// - otherwise the error will be rethrown.
class TryCatchHandler implements HttpHandler {
  TryCatchHandler(this.wrapped, {this.onError});

  final HttpHandler wrapped;
  final Future<HttpResponse> Function(dynamic, StackTrace)? onError;

  @override
  Future<HttpResponse> handle(HttpRequest request) async {
    try {
      return await wrapped.handle(request);
    } on HttpResponse catch (response) {
      return response;
    } catch (error, stacktrace) {
      return await onError?.call(error, stacktrace) ?? (throw error);
    }
  }
}
