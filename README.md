# JSON:API for Dart/Flutter

[JSON:API] is a specification for building APIs in JSON.

This package consists of several libraries:
- The [Client library] to make requests to JSON:API servers
- The [Server library] which is still under development
- The [Document library] model for resources, relationships, identifiers, etc
- The [Query library] to build and parse the query parameters (pagination, sorting, etc)
- The [URI Design library] to build and match URIs for resources, collections, and relationships
- The [HTTP library] to interact with Dart's native HTTP client and server


## Document model
This part assumes that you have a basic understanding of the JSON:API standard. If not, please read the [JSON:API] spec.
The main concept of JSON:API model is the [Resource]. Resources are passed between the client and the server in the
form of a [Document]. A resource has its `type`, `id`, and a map of `attributes`. Resources refer to other resources
with the [Identifier] objects which contain a `type` and `id` of the resource being referred. 
Relationship between resources may be either `toOne` (maps to a single identifier) 
or `toMany` (maps to a list of identifiers).

## Client
[JsonApiClient] is an implementation of the JSON:API client supporting all features of the JSON:API standard:
- fetching resources and collections (both primary and related) 
- creating resources
- deleting resources
- updating resource attributes and relationships
- direct modification of relationships (both to-one and to-many)
- [async processing](https://jsonapi.org/recommendations/#asynchronous-processing)



[JSON:API]: http://jsonapi.org
[Client library]: https://pub.dev/documentation/json_api/latest/client/client-library.html
[Server library]: https://pub.dev/documentation/json_api/latest/server/server-library.html
[Document library]: https://pub.dev/documentation/json_api/latest/document/document-library.html
[Query library]: https://pub.dev/documentation/json_api/latest/query/query-library.html
[URI Design library]: https://pub.dev/documentation/json_api/latest/uri_design/uri_design-library.html
[HTTP library]: https://pub.dev/documentation/json_api/latest/http/http-library.html

[Resource]: https://pub.dev/documentation/json_api/latest/document/Resource-class.html
[Identifier]: https://pub.dev/documentation/json_api/latest/document/Identifier-class.html
[Document]: https://pub.dev/documentation/json_api/latest/document/Document-class.html
[JsonApiClient]: https://pub.dev/documentation/json_api/latest/client/JsonApiClient-class.html