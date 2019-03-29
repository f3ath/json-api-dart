Other JSON:API packages: [Document](https://pub.dartlang.org/packages/json_api_document) | [Server](https://pub.dartlang.org/packages/json_api_server)

---

# JSON:API Client

[JSON:API](http://jsonapi.org) is a specification for building APIs in JSON. This library implements 
a Client (VM, Flutter, Web).

## Features
- Fetching single resources, resource collections, related resources
- Fetching/updating relationships
- Creating/updating/deleting resources
- Collection pagination
- Compound documents
- Asynchronous processing 

## Usage
### Creating a client instance
JSON:API Client uses the Dart's native HttpClient. Depending on the platform, 
you may want to use either the one which comes from `dart:io` or the `BrowserClient`.

In the VM/Flutter you don't need to provide any dependencies:
```dart
import 'package:json_api/client.dart';

final client = JsonApiClient();
```

In a browser use the `BrowserClient`:
```dart
import 'package:json_api/client.dart';
import 'package:http/browser_client.dart';

final client = JsonApiClient(factory: () => BrowserClient());
```

### Making requests
The client provides a set of methods to manipulate resources and relationships.
- Fetching
    - `fetchCollection` - resource collection, either primary or related
    - `fetchResource` - a single resource, either primary or related
    - `fetchRelationship` - a generic relationship (either to-one, to-many or even incomplete)
    - `fetchToOne` - a to-one relationship
    - `fetchToMany` - a to-many relationship
- Manipulating resources
    - `createResource` - creates a new primary resource
    - `updateResource` - updates the existing resource by its type and id
    - `deleteResource` - deletes the existing resource
- Manipulating relationships
    - `replaceToOne` - replaces the existing to-one relationship with a new resource identifier
    - `deleteToOne` - deletes the existing to-one relationship by setting the resource identifier to null
    - `replaceToMany` - replaces the existing to-many relationship with the given set of resource identifiers
    - `addToMany` - adds the given identifiers to the existing to-many relationship
    
These methods accept the target URI and the object to update (except for fetch and delete requests).
You can also pass an optional map of HTTP headers e.g. for authentication. The return value
is `Response` object bearing the HTTP response status and headers and the JSON:API
document with the primary data according to the type of the request. 

Here's a collection fetching example:

```dart
import 'package:json_api/client.dart';

void main() async {
  final client = JsonApiClient();
  final companiesUri = Uri.parse('http://localhost:8080/companies');
  final response = await client.fetchCollection(companiesUri);

  print('Status: ${response.status}');
  print('Headers: ${response.headers}');

  print('The collection page size is ${response.data.collection.length}');

  final resource = response.data.collection.first.toResource();
  print('The first element is ${resource}');

  print('Attributes:');
  resource.attributes.forEach((k, v) => print('$k=$v'));

  print('Relationships:');
  resource.toOne.forEach((k, v) => print('$k=$v'));
  resource.toMany.forEach((k, v) => print('$k=$v'));
}
```


For more usage examples refer to the [functional tests](https://github.com/f3ath/json-api-dart/tree/master/test/functional).
