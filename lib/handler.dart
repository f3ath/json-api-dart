/// This library defines the idea of a composable generic
/// async (request/response) handler.
library handler;

/// A generic async handler
abstract class Handler<Rq, Rs> {
  Future<Rs> call(Rq request);
}

/// A generic async handler function
typedef HandlerFun<Rq, Rs> = Future<Rs> Function(Rq request);

/// Generic handler from function
class FunHandler<Rq, Rs> implements Handler<Rq, Rs> {
  const FunHandler(this._fun);

  final HandlerFun<Rq, Rs> _fun;

  @override
  Future<Rs> call(Rq request) => _fun(request);
}

/// A wrapper over [Handler] which allows logging
class LoggingHandler<Rq, Rs> implements Handler<Rq, Rs> {
  LoggingHandler(this._handler, this._onRequest, this._onResponse);

  final Handler<Rq, Rs> _handler;
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
