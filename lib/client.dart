/// Provides JSON:API client for Flutter, browsers and vm.
///
/// There are two clients implementation provided by this library.
///
/// The firs one, [Client], is the most flexible but low level. It operates
/// generic [Request] and [Response] objects and performs basic operations
/// such as JSON conversion and error handling. It is agnostic to the document
/// structure and accepts any target URIs.
///
/// By default, the [DisposableHandler] is used which internally creates
/// a new instance of Dart built-in HTTP client for each request and then
/// disposes it. If you want more control of the underlying http client,
/// one option can be to use the [PersistentHandler]. To use another HTTP client,
/// such as [dio](https://pub.dev/packages/dio) implement your own wrapper.
///
/// The [codec] performs JSON encoding/decoding. The default implementation
/// uses native `dart:convert`. Provide your own [PayloadCodec] if you need
/// fine-grained control over JSON conversion.
///
/// The [RoutingClient] is a wrapper over [Client] containing methods
/// representing the most common use cases of resource fetching and manipulation.
/// It can conveniently construct and parse JSON:API documents and URIs.
/// The [RoutingClient] should be your default choice.
library client;

export 'package:json_api/src/client/client.dart';
export 'package:json_api/src/client/request.dart';
export 'package:json_api/src/client/response/collection_fetched.dart';
export 'package:json_api/src/client/response/related_resource_fetched.dart';
export 'package:json_api/src/client/response/relationship_fetched.dart';
export 'package:json_api/src/client/response/relationship_updated.dart';
export 'package:json_api/src/client/response/request_failure.dart';
export 'package:json_api/src/client/response/resource_created.dart';
export 'package:json_api/src/client/response/resource_fetched.dart';
export 'package:json_api/src/client/response/resource_updated.dart';
export 'package:json_api/src/client/routing_client.dart';
