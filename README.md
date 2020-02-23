# JSON:API for Dart/Flutter

[JSON:API] is a specification for building APIs in JSON.

This package consists of several libraries:
- The [Document] - the core of this package, describes the JSON:API document structure
- The [Client library] - JSON:API Client for Flutter, Web and Server-side
- The [Server library] - a framework-agnostic JSON:API server implementation
- The [HTTP library] - a thin abstraction of HTTP requests and responses
- The [Query library] - builds and parses the query parameters (pagination, sorting, filtering, etc)
- The [Routing library] - builds and matches URIs for resources, collections, and relationships


## Document model
The main concept of JSON:API model is the [Resource]. 
Resources are passed between the client and the server in the form of a JSON-encodable [Document]. 
A resource has its `type`, `id`, and a map of `attributes`. 
Resources refer to other resources with the an [Identifier] which contains a `type` and `id` of the resource being referred. 
Relationship between resources may be either `toOne` (maps to a single identifier)  or `toMany` (maps to a list of identifiers).

## Client
[JsonApiClient] is an implementation of the JSON:API client supporting all features of the JSON:API standard:
- fetching resources and collections (both primary and related) 
- creating resources
- deleting resources
- updating resource attributes and relationships
- direct modification of relationships (both to-one and to-many)
- [async processing](https://jsonapi.org/recommendations/#asynchronous-processing)

The client returns back a [Response] which contains the HTTP status code, headers and the JSON:API [Document].

Sometimes the request URIs can be inferred from the context. 
For such cases you may use the [RoutingClient] which is a wrapper over the [JsonApiClient] capable of inferring the URIs.
The [RoutingClient] requires an instance of [RouteFactory] to be provided.

[JsonApiClient] itself does not make actual HTTP calls. 
To instantiate [JsonApiClient] you must provide an instance of [HttpHandler] which would act a an HTTP client.
There is an implementation of [HttpHandler] called [DartHttp] which uses the Dart's native http client.
You may use it or make your own if you prefer a different HTTP client.

## Server
This is a framework-agnostic library for implementing a JSON:API server.
It may be used on its own (it has a fully functional server implementation) or as a set of independent components.

### Request lifecycle
#### HTTP request
The server receives an incoming [HttpRequest]. 
It is a thin abstraction over the underlying HTTP system. 
[HttpRequest] carries the headers and the body represented as a String.
When this request is received, your server may decide to check for authentication or other non-JSON:API concerns
to prepare for the request processing or it may decide to fail out with an error response.

#### JSON:API request
The [RequestConverter] then used to convert it to a [JsonApiRequest] which abstracts the JSON:API specific details,
such as the request target (e.g. type, id, relationships) and the decoded body (e.g. [Resource] or [Identifier]).
At this point it is possible to determine if the request is a valid JSON:API request and to read the decoded payload.
You may perform some application-specific logic, e.g. check for authentication.
Each implementation of [JsonApiRequest] has the `handleWith()` to call the right method of the [Controller].

#### Controller
The [Controller] consolidates all methods to process JSON:API requests. 
This is where the actual data manipulation happens.
Every controller method must return an instance of the response. 
Controllers are generic (generalized by the response type), so your implementation may decide to use its own responses.
You are also welcome to use the included [JsonApiResponse] interface and its implementers covering a wide range
of cases.
This library also comes with a particular implementation of the [Controller] called [RepositoryController].
The [RepositoryController] takes care of all JSON:API specific logic (e.g. validation, filtering, resource 
inclusion) and translates the JSON:API requests to calls to a resource [Repository].

#### Repository (optional)
The [Repository] is an interface separating the data storage concerns from the specifics of the API.

#### JSON:API response
When an instance of [JsonApiResponse] is returned from the controller, the [ResponseConverter] 
converts it to an [HttpResponse]. 
The converter takes care of JSON:API transport-layer concerns.
In particular, it:
- generates a proper [Document], including the HATEOAS links or meta-data
- encodes the document to JSON string
- sets the response headers

#### HTTP response
The generated [HttpResponse] is sent to the underlying HTTP system.
This is the final step. 

## HTTP
This library is used by both the Client and the Server to abstract out the HTTP protocol specifics.
The [HttpHandler] interface turns an [HttpRequest] to an [HttpResponse].
The Client consumes an implementation of [HttpHandler] as a low-level HTTP client.
The Server is itself an implementation of [HttpHandler].



[JSON:API]: http://jsonapi.org
[Client library]: https://pub.dev/documentation/json_api/latest/client/client-library.html
[Server library]: https://pub.dev/documentation/json_api/latest/server/server-library.html
[Document library]: https://pub.dev/documentation/json_api/latest/document/document-library.html
[Query library]: https://pub.dev/documentation/json_api/latest/query/query-library.html
[Routing library]: https://pub.dev/documentation/json_api/latest/uri_design/uri_design-library.html
[HTTP library]: https://pub.dev/documentation/json_api/latest/http/http-library.html

[Resource]: https://pub.dev/documentation/json_api/latest/document/Resource-class.html
[Identifier]: https://pub.dev/documentation/json_api/latest/document/Identifier-class.html
[Document]: https://pub.dev/documentation/json_api/latest/document/Document-class.html
[JsonApiClient]: https://pub.dev/documentation/json_api/latest/client/JsonApiClient-class.html