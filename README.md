# JSON:API for Dart/Flutter

[JSON:API] is a specification for building APIs in JSON.

This package consists of several libraries:
- The [Document] - the core of this package, describes the JSON:API document structure
- The [Client library] - JSON:API Client for Flutter, Web and Server-side
- The [Server library] - a framework-agnostic JSON:API server implementation
- The [HTTP library] - a thin abstraction of HTTP requests and responses
- The [Query library] - builds and parses the query parameters (page, sorting, filtering, etc)
- The [Routing library] - builds and matches URIs for resources, collections, and relationships

## Document model
The main concept of JSON:API model is the [Resource]. 
Resources are passed between the client and the server in the form of a JSON-encodable [Document]. 

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
Instead, it calls the underlying [HttpHandler] which acts as an HTTP client (must be passed to the constructor).
The library comes with an implementation of [HttpHandler] called [DartHttp] which uses the Dart's native http client.

## Server
This is a framework-agnostic library for implementing a JSON:API server.
It may be used on its own (a fully functional server implementation is included) or as a set of independent components.

### Request lifecycle
#### HTTP request
The server receives an incoming [HttpRequest] containing the HTTP headers and the body represented as a String.
When this request is received, your server may decide to check for authentication or other non-JSON:API concerns
to prepare for the request processing, or it may decide to fail out with an error response.

#### JSON:API request
The [RequestConverter] is then used to convert the HTTP request to a [JsonApiRequest].
[JsonApiRequest] abstracts the JSON:API specific details,
such as the request target (a collection, a resource or a relationship) and the decoded body (e.g. [Resource] or [Identifier]).
At this point it is possible to determine whether the request is a valid JSON:API request and to read the decoded payload.
You may perform some application-specific logic, e.g. check for authentication.
Each implementation of [JsonApiRequest] has the `handleWith()` method to dispatch a call to the right method of the [Controller].

#### Controller
The [Controller] consolidates all methods to process JSON:API requests. 
Every controller method must return an instance of [JsonApiResponse] (or another type, the controller is generic). 
This library comes with a particular implementation of the [Controller] called [RepositoryController].
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

## URL Queries
This is a set of classes for building avd parsing some URL query parameters defined in the standard.
- [Fields] for [Sparse fieldsets]
- [Include] for [Inclusion of Related Resources]
- [Page] for [Collection Pagination]
- [Sort] for [Collection Sorting]

## Routing
Defines the logic for constructing and matching URLs for resources, collections and relationships.
The URL construction is used by both the Client (See [RoutingClient] for instance) and the Server libraries.
The [StandardRouting] implements the [Recommended URL design].

[JSON:API]: http://jsonapi.org
[Sparse fieldsets]: https://jsonapi.org/format/#fetching-sparse-fieldsets
[Inclusion of Related Resources]: https://jsonapi.org/format/#fetching-includes
[Collection Pagination]: https://jsonapi.org/format/#fetching-pagination
[Collection Sorting]: https://jsonapi.org/format/#fetching-sorting
[Recommended URL design]: https://jsonapi.org/recommendations/#urls

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


[Response]: https://pub.dev/documentation/json_api/latest/client/Response-class.html
[RoutingClient]: https://pub.dev/documentation/json_api/latest/client/RoutingClient-class.html
[DartHttp]: https://pub.dev/documentation/json_api/latest/client/DartHttp-class.html


[RequestConverter]: https://pub.dev/documentation/json_api/latest/server/RequestConverter-class.html
[JsonApiResponse]: https://pub.dev/documentation/json_api/latest/server/JsonApiResponse-class.html
[ResponseConverter]: https://pub.dev/documentation/json_api/latest/server/ResponseConverter-class.html
[JsonApiRequest]: https://pub.dev/documentation/json_api/latest/server/JsonApiRequest-class.html
[Controller]: https://pub.dev/documentation/json_api/latest/server/Controller-class.html
[Repository]: https://pub.dev/documentation/json_api/latest/server/Repository-class.html
[RepositoryController]: https://pub.dev/documentation/json_api/latest/server/RepositoryController-class.html


[HttpHandler]: https://pub.dev/documentation/json_api/latest/http/HttpHandler-class.html
[HttpRequest]: https://pub.dev/documentation/json_api/latest/http/HttpRequest-class.html
[HttpResponse]: https://pub.dev/documentation/json_api/latest/http/HttpResponse-class.html


[Fields]: https://pub.dev/documentation/json_api/latest/query/Fields-class.html
[Include]: https://pub.dev/documentation/json_api/latest/query/Include-class.html
[Page]: https://pub.dev/documentation/json_api/latest/query/Page-class.html
[Sort]: https://pub.dev/documentation/json_api/latest/query/Sort-class.html


[RouteFactory]: https://pub.dev/documentation/json_api/latest/routing/RouteFactory-class.html
[StandardRouting]: https://pub.dev/documentation/json_api/latest/routing/StandardRouting-class.html