# [JSON:API](http://jsonapi.org) v1.0 HTTP Client

This is a super simple implementation of JSON:API Client.

### Usage example
```dart
import 'package:json_api/json_api.dart';
import 'package:json_api_document/json_api_document.dart';

void main() async {
  final client = JsonApiClient(baseUrl: 'http://localhost:8888');
  final response = await client.fetchResource('/example');
  print((response.document as DataDocument).data.resources.first.attributes); // Attributes{message: Hello world!}
}
```

### Supported methods

- `addToMany`
Adds the identifiers to the to-many relationship via POST request to the url.
- `createResource`
Creates a new resource sending a POST request to the url.
- `deleteResource`
Deletes the resource sending a DELETE request to the url.
- `deleteToMany`
Deletes the identifiers from the to-many relationship via DELETE request to the url.
- `deleteToOne`
Removes a to-one relationship sending PATCH request with "null" data to the url.
- `fetchRelationship`
Fetches a Document containing identifier(s) from the given url.
- `fetchResource`
Fetches a Document containing resource(s) from the given url.
- `setToMany`
Updates (replaces!) a to-many relationship sending the identifiers via PATCH request to the url.
- `setToOne`
Creates or updates a to-one relationship sending a corresponding identifier via PATCH request to the url.
- `updateResource`
Updates the resource sending a PATCH request to the url.
