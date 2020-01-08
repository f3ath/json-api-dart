import 'package:http/http.dart';
import 'package:json_api/client.dart';

/// Start `dart example/server.dart` first
void main() async {
  final httpClient = Client();
  final jsonApiClient = JsonApiClient(httpClient);
  final url = Uri.parse('http://localhost:8080/companies');
  final response = await jsonApiClient.fetchCollection(url);
  httpClient.close(); // Don't forget to close the http client
  print('The collection page size is ${response.data.collection.length}');
  final resource = response.data.unwrap().first;
  print('The last element is ${resource}');
  resource.attributes.forEach((k, v) => print('Attribute $k is $v'));
}
