import 'package:http/http.dart';
import 'package:json_api/client.dart';

void main() async {
  final httpClient = Client();
  final jsonApiClient = JsonApiClient(httpClient);
  final companiesUri = Uri.parse('http://localhost:8080/companies');
  final response = await jsonApiClient.fetchCollection(companiesUri);
  httpClient.close();
  print('Status: ${response.status}');
  print('Headers: ${response.headers}');

  final resource = response.data.unwrap().first;

  print('The collection page size is ${response.data.collection.length}');
  print('The first element is ${resource}');
  print('Attributes:');
  resource.attributes.forEach((k, v) => print('$k=$v'));
  print('Relationships:');
  resource.toOne.forEach((k, v) => print('$k=$v'));
  resource.toMany.forEach((k, v) => print('$k=$v'));
}
