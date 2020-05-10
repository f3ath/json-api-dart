import 'package:json_api/client.dart';

Future<void> seedResources(JsonApiClient client) async {
  await client
      .createResource('people', '1', attributes: {'name': 'Martin Fowler'});
  await client.createResource('people', '2', attributes: {'name': 'Kent Beck'});
  await client
      .createResource('people', '3', attributes: {'name': 'Robert Martin'});
  await client.createResource('companies', '1',
      attributes: {'name': 'Addison-Wesley Professional'});
  await client
      .createResource('companies', '2', attributes: {'name': 'Prentice Hall'});
  await client.createResource('books', '1', attributes: {
    'title': 'Refactoring',
    'ISBN-10': '0134757599'
  }, one: {
    'publisher': Identifier('companies', '1'),
  }, many: {
    'authors': [Identifier('people', '1'), Identifier('people', '2')]
  });
}
