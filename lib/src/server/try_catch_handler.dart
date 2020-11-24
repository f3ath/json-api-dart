import 'package:json_api/handler.dart';
import 'package:json_api/src/server/json_api_response.dart';

/// Calls the wrapped handler within a try-catch block.
/// When a [JsonApiResponse] is thrown, returns it.
/// When any other error is thrown, ties to convert it using [ErrorConverter],
/// or returns an HTTP 500.
class TryCatchHandler<Rq, Rs> implements Handler<Rq, Rs> {
  TryCatchHandler(this._handler, this._onError);

  final Handler<Rq, Rs> _handler;
  final Handler<Object, Rs> _onError;

  /// Handles the request by calling the appropriate method of the controller
  @override
  Future<Rs> call(Rq request) async {
    try {
      return await _handler(request);
    } on Rs catch (response) {
      return response;
    } catch (error) {
      return await _onError.call(error);
    }
  }
}
