import 'package:json_api/handler.dart';

class ChainErrorConverter<E, Rs> implements Handler<E, Rs> {
  ChainErrorConverter(
      Iterable<Handler<E, Rs /*?*/ >> chain, this._defaultResponse) {
    _chain.addAll(chain);
  }

  final _chain = <Handler<E, Rs /*?*/ >>[];
  final Future<Rs> Function() _defaultResponse;

  @override
  Future<Rs> call(E error) async {
    for (final h in _chain) {
      final r = await h.call(error);
      if (r != null) return r;
    }
    return await _defaultResponse();
  }
}
