import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/uri_design.dart';

/// Start `dart example/server/server.dart` first
void main() async {
  final base = Uri.parse('http://localhost:8080');
  final client = UriAwareClient(UriDesign.standard(base));
  await client.createResource(
      Resource('messages', '1', attributes: {'text': 'Hello World'}));
  client.close();
}
