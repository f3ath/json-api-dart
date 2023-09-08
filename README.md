# JSON:API Client and Server

TL;DR:
```dart
import 'package:http_interop_http/http_interop_http.dart';
import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';

void main() async {
  /// Define the server's base URL
  final baseUri = 'http://localhost:8080';

  /// Use the standard recommended URL structure or implement your own
  final uriDesign = StandardUriDesign(Uri.parse(baseUri));

  /// The [RoutingClient] is most likely the right choice.
  /// It has methods covering many standard use cases.
  final client = RoutingClient(uriDesign, Client(OneOffHandler()));

  try {
    /// Fetch the collection.
    /// See other methods to query and manipulate resources.
    final response = await client.fetchCollection('colors');

    final resources = response.collection;
    resources.map((resource) => resource.attributes).forEach((attr) {
      final name = attr['name'];
      final red = attr['red'];
      final green = attr['green'];
      final blue = attr['blue'];
      print('$name - $red:$green:$blue');
    });
  } on RequestFailure catch (e) {
    /// Catch error response
    for (var error in e.errors) {
      print(error.title);
    }
  }
}
```
This is a work-in-progress. You can help it by submitting a PR with a feature or documentation improvements.


[JSON:API]: https://jsonapi.org
