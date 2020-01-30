import 'package:json_api/client.dart';
import 'package:json_api/uri_design.dart';

/// This example shows how to use the JSON:API client.
/// Run the server first!
void main() {
  /// Use the same URI design as the server
  final uriDesign = UriDesign.standard(Uri.parse('http://localhost:8080'));
  /// There are two clients in this library:
  /// - JsonApiClient, the main implementation, most flexible but a bit verbose
  /// - SimpleClient, less boilerplate but not as flexible
  /// The example will show both in parallel
  final client = JsonApiClient();
  final simpleClient = SimpleClient(uriDesign);




}
