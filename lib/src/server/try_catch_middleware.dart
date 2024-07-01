import 'package:http_interop/http_interop.dart';

/// An [Handler] wrapper which calls the wrapped [handler] and does
/// the following:
/// - when an instance of [Response] is returned or thrown by the
///   wrapped handler, the response is returned
/// - when another error is thrown by the wrapped handler and
///   the [onError] callback is set, the error will be converted to a response
/// - otherwise the error will be rethrown.

Handler tryCatchMiddleware(Handler handler,
        {Future<Response> Function(dynamic, StackTrace)? onError}) =>
    (Request request) async {
      try {
        return await handler(request);
      } on Response catch (response) {
        return response;
      } catch (error, stacktrace) {
        return await onError?.call(error, stacktrace) ?? (throw error);
      }
    };
