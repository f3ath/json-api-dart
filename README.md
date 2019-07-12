[JSON:API](http://jsonapi.org) is a specification for building APIs in JSON. 

# Client
Quick usage example:
```dart
import 'package:json_api/json_api.dart';

void main() async {
  final client = JsonApiClient();
  final companiesUri = Uri.parse('http://localhost:8080/companies');
  final response = await client.fetchCollection(companiesUri);

  print('Status: ${response.status}');
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
To see this in action:
 
 1. start the server:
```
$ dart example/cars_server.dart
Listening on 127.0.0.1:8080
```
2. run the script:
```
$ dart example/fetch_collection.dart 
Status: 200
Headers: {x-frame-options: SAMEORIGIN, content-type: application/vnd.api+json, x-xss-protection: 1; mode=block, x-content-type-options: nosniff, transfer-encoding: chunked, access-control-allow-origin: *}
The collection page size is 1
The first element is Resource(companies:1)
Attributes:
name=Tesla
nasdaq=null
updatedAt=2019-07-07T13:08:18.125737
Relationships:
hq=Identifier(cities:2)
models=[Identifier(models:1), Identifier(models:2), Identifier(models:3), Identifier(models:4)]
```

The client provides a set of methods to deal with resources and relationships.
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
You can also pass an optional map of HTTP headers, e.g. for authentication. The return value
is a [Response] object. 

You can get the status of the [Response] from either [Response.status] or one of the following properties: 
- [Response.isSuccessful]
- [Response.isFailed]
- [Response.isAsync] (see [Asynchronous Processing])

The Response also contains the raw [Response.status] and a map of HTTP headers.
Two headers used by JSON:API can be accessed directly for your convenience:
- [Response.location] holds the `Location` header used in creation requests
- [Response.contentLocation] holds the `Content-Location` header used for [Asynchronous Processing]

The most important part of the Response is the [Response.document] containing the JSON:API document sent by the server (if any). 
If the document has the Primary Data, you can use [Response.data] shortcut to access it directly.

#### Included resources
If you requested related resources to be included in the response (see [Compound Documents]) and the server fulfilled
your request, the [PrimaryData.included] property will contain them.

#### Errors
For unsuccessful operations the [Response.data] property will be null. 
If the server decided to include the error details in the response, those can be found in the  [Document.errors] property.

#### Async processing
Some servers may support [Asynchronous Processing].
When the server responds with `202 Accepted`, the client expects the Primary Data to always be a Resource (usually
representing a job queue). In this case, [Response.document] and [Response.data] will be null. Instead, 
the response document will be placed to [Response.asyncDocument] (and [Response.asyncData]). 
Also in this case the [Response.contentLocation]
will point to the job queue resource. You can fetch the job queue resource periodically and check
the type of the returned resource. Once the operation is complete, the request will return the created resource.

# Server
The server included in this package is still under development. It is not suitable for real production environment yet
except maybe for really simple demo or testing cases.

## URL Design
##


[Response]: https://pub.dartlang.org/documentation/json_api/latest/json_api/Response-class.html
[Response.data]: https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/data.html
[Response.document]: https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/document.html
[Response.isSuccessful]: https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/isSuccessful.html
[Response.isFailed]: https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/isFailed.html
[Response.isAsync]: https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/isAsync.html
[Response.location]: https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/location.html
[Response.contentLocation]: https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/contentLocation.html
[Response.status]: https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/status.html
[Response.asyncDocument]: https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/asyncDocument.html
[Response.asyncData]: https://pub.dartlang.org/documentation/json_api/latest/json_api/Response/asyncData.html
[PrimaryData.included]: https://pub.dev/documentation/json_api/latest/document/PrimaryData/included.html
[Document.errors]: https://pub.dev/documentation/json_api/latest/document/Document/errors.html

[Asynchronous Processing]: https://jsonapi.org/recommendations/#asynchronous-processing
[Compound Documents]: https://jsonapi.org/format/#document-compound-documents