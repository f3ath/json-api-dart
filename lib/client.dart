import 'package:json_api/document.dart';

export 'package:json_api/src/client/dart_http_client.dart';

abstract class Client implements ResourceFetcher, CollectionFetcher {
  Future<Response<CollectionDocument>> fetchCollection(Uri uri,
      {Map<String, String> headers});

  Future<Response<ResourceDocument>> fetchResource(Uri uri,
      {Map<String, String> headers});

  Future<Response<ToOne>> fetchToOne(Uri uri, {Map<String, String> headers});

  Future<Response<ToMany>> fetchToMany(Uri uri, {Map<String, String> headers});

  Future<Response<ResourceDocument>> createResource(Uri uri, Resource r,
      {Map<String, String> headers});

  Future<Response<ToMany>> addToMany(Uri uri, Iterable<Identifier> ids,
      {Map<String, String> headers});
}
