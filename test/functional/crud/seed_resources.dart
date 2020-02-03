import 'package:json_api/client.dart';
import 'package:json_api/document.dart';

Future<void> seedResources(SimpleClient client) async {
  await client.createResource(
      Resource('people', '1', attributes: {'name': 'Martin Fowler'}));
  await client.createResource(
      Resource('people', '2', attributes: {'name': 'Kent Beck'}));
  await client.createResource(
      Resource('people', '3', attributes: {'name': 'Robert Martin'}));
  await client.createResource(Resource('companies', '1',
      attributes: {'name': 'Addison-Wesley Professional'}));
  await client.createResource(
      Resource('companies', '2', attributes: {'name': 'Prentice Hall'}));
  await client.createResource(Resource('books', '1', attributes: {
    'title': 'Refactoring',
    'ISBN-10': '0134757599'
  }, toOne: {
    'publisher': Identifier('companies', '1')
  }, toMany: {
    'authors': [Identifier('people', '1'), Identifier('people', '2')]
  }));
}
