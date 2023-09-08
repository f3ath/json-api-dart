import 'package:http/http.dart' as http;
import 'package:http_interop_http/http_interop_http.dart';
import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';

void main() async {
  /// Define the server's base URL
  final baseUri = 'http://localhost:8080';

  /// Use the standard recommended URL structure or implement your own
  final uriDesign = StandardUriDesign(Uri.parse(baseUri));

  /// This is the Dart's standard HTTP client.
  /// Do not forget to close it in the end.
  final httpClient = http.Client();

  /// This is the adapter which decouples this JSON:API implementation
  /// from the HTTP client.
  /// Learn more: https://pub.dev/packages/http_interop
  final httpHandler = ClientWrapper(httpClient);

  /// This is the basic JSON:API client. It is flexible but not very convenient
  /// to use, because you would need to remember a lot of JSON:API protocol details.
  /// We will use another wrapper on top of it.
  final jsonApiClient = Client(httpHandler);

  /// The [RoutingClient] is most likely the right choice.
  /// It is called routing because it routes the calls to the correct
  /// URLs depending on the use case. Take a look at its methods, they cover
  /// all the standard scenarios specified by the JSON:API standard.
  final client = RoutingClient(uriDesign, jsonApiClient);

  try {
    /// Fetch the collection.
    /// See other methods to query and manipulate resources.
    final response = await client.fetchCollection('colors');

    /// The fetched collection allows us to iterate over the resources
    /// and to look into their attributes
    for (final resource in response.collection) {
      final {
        'name': name,
        'red': red,
        'green': green,
        'blue': blue,
      } = resource.attributes;
      print('${resource.type}:${resource.id}');
      print('$name - $red:$green:$blue');
    }
  } on RequestFailure catch (e) {
    /// Catch error response
    for (final error in e.errors) {
      print(error.title);
    }
  }

  /// Free up the resources before exit.
  httpClient.close();
}
