import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';

/// Start `dart example/server/server.dart` first
void main() async {
  final url = Uri.parse('http://localhost:8080');
  final client = UrlAwareClient(RecommendedRouting(url));
  await client.createResource(
      Resource('messages', '1', attributes: {'text': 'Hello World'}));
  client.close();
}
