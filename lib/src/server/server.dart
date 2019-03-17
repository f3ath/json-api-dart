import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/page.dart';
import 'package:json_api/src/server/route.dart';
import 'package:json_api/src/server/uri_builder.dart';

class JsonApiServer {
  final UriBuilder url;
  final String allowOrigin;

  JsonApiServer(this.url, {this.allowOrigin = '*'});

  Future write(HttpResponse response, int status,
      {Document document, Map<String, String> headers = const {}}) {
    response.statusCode = status;
    headers.forEach(response.headers.add);
    if (allowOrigin != null) {
      response.headers.set('Access-Control-Allow-Origin', allowOrigin);
    }
    if (document != null) {
      response.write(json.encode(document));
    }
    return response.close();
  }

  Future collection(HttpResponse response, CollectionRoute route,
          Iterable<Resource> resource,
          {Page page}) =>
      write(response, 200,
          document: Document(
            ResourceCollectionData(resource.map(ResourceJson.fromResource),
                self: Link(route.self(url, parameters: route.parameters)),
                pagination: page == null
                    ? Pagination.empty()
                    : Pagination.fromLinks(page.map((_) =>
                        Link(route.self(url, parameters: _.parameters))))),
          ));

  Future error(HttpResponse response, int status, List<JsonApiError> errors) =>
      write(response, status, document: Document.error(errors));

  Future relatedCollection(HttpResponse response, RelatedRoute route,
          Iterable<Resource> collection) =>
      write(response, 200,
          document: Document(ResourceCollectionData(
              collection.map(ResourceJson.fromResource),
              self: Link(route.self(url)))));

  Future relatedResource(
          HttpResponse response, RelatedRoute route, Resource resource) =>
      write(response, 200,
          document: Document(ResourceData(ResourceJson.fromResource(resource),
              self: Link(route.self(url)))));

  Future resource(HttpResponse response, ResourceRoute route, Resource resource,
          {Iterable<Resource> included}) =>
      write(response, 200,
          document: Document(
              ResourceData(ResourceJson.fromResource(resource),
                  self: Link(route.self(url))),
              included: included?.map(ResourceJson.fromResource)));

  Future toMany(HttpResponse response, RelationshipRoute route,
          Iterable<Identifier> collection) =>
      write(response, 200,
          document: Document(ToMany(
              collection.map(IdentifierJson.fromIdentifier),
              self: Link(route.self(url)),
              related: Link(route.related(url)))));

  Future toOne(HttpResponse response, RelationshipRoute route, Identifier id) =>
      write(response, 200,
          document: Document(ToOne(nullable(IdentifierJson.fromIdentifier)(id),
              self: Link(route.self(url)), related: Link(route.related(url)))));

  Future meta(HttpResponse response, ResourceRoute route,
          Map<String, Object> meta) =>
      write(response, 200, document: Document.empty(meta));

  Future created(
          HttpResponse response, CollectionRoute route, Resource resource) =>
      write(response, 201,
          document: Document(ResourceData(ResourceJson.fromResource(resource))),
          headers: {
            'Location': url.resource(resource.type, resource.id).toString()
          });
}
