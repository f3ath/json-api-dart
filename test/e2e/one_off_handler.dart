import 'package:http/http.dart' as h;
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_http/http_interop_http.dart';

Future<Response> oneOffHandler(Request request) async {
  final client = h.Client();
  final response = await client.handleInterop(request);
  client.close();
  return response;
}
