library handler;

/// A generic async handler
abstract class AsyncHandler<Rq, Rs> {
  static AsyncHandler<Rq, Rs> lambda<Rq, Rs>(
          Future<Rs> Function(Rq request) fun) =>
      _FunHandler(fun);

  Future<Rs> call(Rq request);
}

/// A wrapper over [AsyncHandler] which allows logging
class LoggingHandler<Rq, Rs> implements AsyncHandler<Rq, Rs> {
  LoggingHandler(this._handler,
      {void Function(Rq request)? onRequest,
      void Function(Rs response)? onResponse})
      : _onRequest = onRequest ?? _nothing,
        _onResponse = onResponse ?? _nothing;

  final AsyncHandler<Rq, Rs> _handler;
  final void Function(Rq request) _onRequest;
  final void Function(Rs response) _onResponse;

  @override
  Future<Rs> call(Rq request) async {
    _onRequest(request);
    final response = await _handler(request);
    _onResponse(response);
    return response;
  }
}

/// Calls the wrapped handler within a try-catch block.
/// When a response object is thrown, returns it.
/// When any other error is thrown, converts it using the callback.
class TryCatchHandler<Rq, Rs extends Object> implements AsyncHandler<Rq, Rs> {
  TryCatchHandler(this._handler, this._onError);

  final AsyncHandler<Rq, Rs> _handler;
  final Future<Rs> Function(dynamic error) _onError;

  @override
  Future<Rs> call(Rq request) async {
    try {
      return await _handler(request);
    } on Rs catch (response) {
      return response;
    } catch (error) {
      return await _onError(error);
    }
  }
}

class _FunHandler<Rq, Rs> implements AsyncHandler<Rq, Rs> {
  _FunHandler(this.handle);

  final Future<Rs> Function(Rq request) handle;

  @override
  Future<Rs> call(Rq request) => handle(request);
}

void _nothing(dynamic any) {}
