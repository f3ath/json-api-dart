import 'package:json_api/src/http/http_response.dart';
import 'package:json_api/src/server/error_converter.dart';

class ChainErrorConverter implements ErrorConverter {
  ChainErrorConverter(Iterable<ErrorConverter> chain) {
    _chain.addAll(chain);
  }

  final _chain = <ErrorConverter>[];

  @override
  Future<HttpResponse /*?*/ > convert(Object error) async {
    for (final h in _chain) {
      final r = await h.convert(error);
      if (r != null) return r;
    }
    return null;
  }
}
