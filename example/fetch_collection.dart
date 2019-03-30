import 'package:json_api/json_api.dart';

void main() async {
  final client = JsonApiClient();
  final companiesUri = Uri.parse('http://localhost:8080/companies');
  final response = await client.fetchCollection(companiesUri);
  print('Status: ${response.status}');
  print('Headers: ${response.headers}');

  final resource = response.data.collection.first.toResource();

  print('The collection page size is ${response.data.collection.length}');
  print('The first element is ${resource}');
  print('Attributes:');
  resource.attributes.forEach((k, v) => print('$k=$v'));
  print('Relationships:');
  resource.toOne.forEach((k, v) => print('$k=$v'));
  resource.toMany.forEach((k, v) => print('$k=$v'));
}
