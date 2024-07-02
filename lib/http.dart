import 'package:http_interop/http_interop.dart';

class StatusCode {
  const StatusCode(this.value);

  static const ok = 200;
  static const created = 201;
  static const accepted = 202;
  static const noContent = 204;
  static const badRequest = 400;
  static const notFound = 404;
  static const methodNotAllowed = 405;
  static const unacceptable = 406;
  static const unsupportedMediaType = 415;

  final int value;

  /// True for the requests processed asynchronously.
  /// @see https://jsonapi.org/recommendations/#asynchronous-processing).
  bool get isPending => value == accepted;

  /// True for successfully processed requests
  bool get isSuccessful => value >= ok && value < 300 && !isPending;

  /// True for failed requests (i.e. neither successful nor pending)
  bool get isFailed => !isSuccessful && !isPending;
}

Handler loggingMiddleware(Handler handler,
        {Function(Request request)? onRequest,
        Function(Response response)? onResponse}) =>
    (Request request) async {
      onRequest?.call(request);
      final response = await handler(request);
      onResponse?.call(response);
      return response;
    };

/// CORS middleware
Handler corsMiddleware(Handler handler) => (Request request) async {
      final corsHeaders = {
        'Access-Control-Allow-Origin': [request.headers.last('origin') ?? '*'],
        'Access-Control-Expose-Headers': ['Location'],
      };

      if (request.method == 'options') {
        const methods = ['POST', 'GET', 'DELETE', 'PATCH', 'OPTIONS'];
        return Response(
            204,
            Body(),
            Headers.from({
              ...corsHeaders,
              'Access-Control-Allow-Methods':
                  request.headers['Access-Control-Request-Method'] ?? methods,
              'Access-Control-Allow-Headers':
                  request.headers['Access-Control-Request-Headers'] ?? ['*'],
            }));
      }
      final response = await handler(request);
      response.headers.addAll(corsHeaders);
      return response;
    };

extension HeaderExt on Headers {
  String? last(String key) {
    final v = this[key];
    return (v != null && v.isNotEmpty) ? v.last : null;
  }
}
