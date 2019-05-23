Other JSON:API packages: [Document](https://pub.dartlang.org/packages/json_api_document) | [Server](https://pub.dartlang.org/packages/json_api_server)

---

# JSON:API Client

[JSON:API](http://jsonapi.org) is a specification for building APIs in JSON. This package implements 
the Client.

## Features
- Fetching single resources, resource collections, related resources
- Fetching/updating relationships
- Creating/updating/deleting resources
- Collection pagination
- Compound documents (included resources)
- Asynchronous processing 

## Usage
### Creating a client instance
JSON:API Client uses the Dart's native HttpClient. Depending on the platform, 
you may want to use either the one which comes from `dart:io` or the `BrowserClient`.

In the VM/Flutter you don't need to provide any dependencies:
```dart
import 'package:json_api/json_api.dart';

final client = JsonApiClient();
```

In a browser use the `BrowserClient`:
```dart
import 'package:json_api/json_api.dart';
import 'package:http/browser_json_api.dart';

final client = JsonApiClient(factory: () => BrowserClient());
```

### Making requests
The client provides a set of methods to manipulate resources and relationships.
- Fetching
    - [fetchCollection](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/fetchCollection.html) - resource collection, either primary or related
    - [fetchResource](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/fetchResource.html) - a single resource, either primary or related
    - [fetchRelationship](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/fetchRelationship.html) - a generic relationship (either to-one, to-many or even incomplete)
    - [fetchToOne](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/fetchToOne.html) - a to-one relationship
    - [fetchToMany](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/fetchToMany.html) - a to-many relationship
- Manipulating resources
    - [createResource](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/createResource.html) - creates a new primary resource
    - [updateResource](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/updateResource.html) - updates the existing resource by its type and id
    - [deleteResource](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/deleteResource.html) - deletes the existing resource
- Manipulating relationships
    - [replaceToOne](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/replaceToOne.html) - replaces the existing to-one relationship with a new resource identifier
    - [deleteToOne](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/deleteToOne.html) - deletes the existing to-one relationship by setting the resource identifier to null
    - [replaceToMany](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/replaceToMany.html) - replaces the existing to-many relationship with the given set of resource identifiers
    - [addToMany](https://pub.dartlang.org/documentation/json_api/latest/json_api/JsonApiClient/addToMany.html) - adds the given identifiers to the existing to-many relationship
    
These methods accept the target URI and the object to update (except for fetch and delete requests).
You can also pass an optional map of HTTP headers e.g. for authentication. The return value
is [Response](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response-class.html) object bearing the 
HTTP response status and headers and the JSON:API
document with the primary data according to the type of the request. 

Here's a collection fetching example:

```dart
import 'package:json_api/json_api.dart';

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

### The Response object
The Client always returns a [Response object](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response-class.html)
which indicates either a successful, failed, or async (neither failed nor successful yet, see [here](https://jsonapi.org/recommendations/#asynchronous-processing)) operation.
You can determine which one you have by reading these properties:
- [isSuccessful](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/isSuccessful.html)
- [isFailed](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/isFailed.html)
- [isAsync](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/isAsync.html)

The Response also contains [HTTP status](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/status.html)
and a map of [HTTP headers](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/headers.html).
Two headers used by JSON:API can be accessed directly for your convenience:
- [location](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/location.html) - 
the `Location:` header used in creation requests
- [contentLocation](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/contentLocation.html) - 
the `Content-Location:` header used for asynchronous processing

### The Response Document
The most important part of the Response is the [document](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/document.html)
property which contains the JSON:API document sent by the server (if any). If the document has Primary Data, you
can use [data](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/data.html) 
shortcut to access it directly. Like the Document, the Response is generalized by the expected Primary Data
which depends of the operation. The Document and the rest of the JSON:API object model are parts of [json_api_document](https://pub.dartlang.org/packages/json_api_document)
which is a separate package. Refer to that package for [complete API documentation](https://pub.dartlang.org/documentation/json_api_document/latest/). 
This README only gives a brief overview.

#### Successful responses
Most of the times when the response is successful, you can read the [data](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/data.html)
property directly. It will be either a [primary resource](https://pub.dartlang.org/documentation/json_api_document/latest/json_api_document/ResourceData-class.html)
, primary [resource collection](https://pub.dartlang.org/documentation/json_api_document/latest/json_api_document/ResourceCollectionData-class.html), 
or a relationship: [to-one](https://pub.dartlang.org/documentation/json_api_document/latest/json_api_document/ToOne-class.html)
or [to-many](https://pub.dartlang.org/documentation/json_api_document/latest/json_api_document/ToMany-class.html). 
The collection-like data may also contain [pagination links](https://pub.dartlang.org/documentation/json_api_document/latest/json_api_document/Pagination-class.html).

#### Included resources
If you requested related resources to be included in the response (see [Compound Documents](https://jsonapi.org/format/#document-compound-documents)) and the server fulfilled
your request, the [included](https://pub.dartlang.org/documentation/json_api_document/latest/json_api_document/PrimaryData/included.html) property will contain them.

#### Errors
For unsuccessful operations the [data](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/data.html)
property will be null. If the server decided to include the error details in the response, those can be found in the 
[errors](https://pub.dartlang.org/documentation/json_api_document/latest/json_api_document/Document/errors.html) property.


#### Async processing
Some servers may support [Asynchronous Processing](https://jsonapi.org/recommendations/#asynchronous-processing).
When the server responds with `202 Accepted`, the client expects the Primary Data to always be a Resource (usually
representing a job queue). In this case, the [document](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/document.html)
and the [data](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/data.html) 
properties of the Response will be null. Instead, 
the response document will be placed to [asyncDocument](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/asyncDocument.html)
(and [asyncData](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/asyncData.html)). 
Also in this case the [contentLocation](https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/contentLocation.html)
will point to the job queue resource. You can fetch the job queue resource periodically and check
the type of the returned resource. Once the operation is complete, the request will return the created resource.

### Further reading
For more usage examples refer to the [functional tests](https://github.com/f3ath/json-api-dart/tree/master/test/functional).
