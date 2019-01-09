import 'package:json_api/json_api.dart';
import 'package:json_api_document/json_api_document.dart';

/// This is a simple example of JsonApiClient.
///
/// Don't forget to start server.dart first!
void main() async {
  final client = JsonApiClient(baseUrl: 'http://localhost:8888');
  final response = await client.fetchResource('/example');
  print((response.document as DataDocument).data.resources.first.attributes);
}
