import 'package:http_interop/http_interop.dart' as interop;

/// An [HttpHandler] wrapper which calls the [wrapped] handler and does
/// the following:
/// - when an instance of [interop.Response] is returned or thrown by the
///   [wrapped] handler, the response is returned
/// - when another error is thrown by the [wrapped] handler and
///   the [onError] callback is set, the error will be converted to a response
/// - otherwise the error will be rethrown.
class TryCatchHandler implements interop.Handler {
  TryCatchHandler(this.wrapped, {this.onError});

  final interop.Handler wrapped;
  final Future<interop.Response> Function(dynamic, StackTrace)? onError;

  @override
  Future<interop.Response> handle(interop.Request request) async {
    try {
      return await wrapped.handle(request);
    } on interop.Response catch (response) {
      return response;
    } catch (error, stacktrace) {
      return await onError?.call(error, stacktrace) ?? (throw error);
    }
  }
}
