import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/request.dart';

abstract class ResponseFactory {
  HttpResponse error(int status,
      {Iterable<ErrorObject> errors, Map<String, String> headers});

  HttpResponse noContent();

  HttpResponse primaryResource(
      Request<ResourceTarget> request, Resource resource,
      {Iterable<Resource> include});

  HttpResponse relatedResource(
      Request<RelatedTarget> request, Resource resource,
      {Iterable<Resource> include});

  HttpResponse createdResource(
      Request<CollectionTarget> request, Resource resource);

  HttpResponse primaryCollection(
      Request<CollectionTarget> request, Collection<Resource> collection,
      {Iterable<Resource> include});

  HttpResponse relatedCollection(
      Request<RelatedTarget> request, Collection<Resource> collection,
      {List<Resource> include});

  HttpResponse relationshipToOne(
      Request<RelationshipTarget> request, Identifier identifier);

  HttpResponse relationshipToMany(
      Request<RelationshipTarget> request, Iterable<Identifier> identifiers);
}

class HttpResponseFactory implements ResponseFactory {
  HttpResponseFactory(this._uri);

  final UriFactory _uri;

  @override
  HttpResponse error(int status,
          {Iterable<ErrorObject> errors, Map<String, String> headers}) =>
      HttpResponse(status,
          body: jsonEncode(Document.error(errors ?? [])),
          headers: {...(headers ?? {}), 'Content-Type': Document.contentType});

  @override
  HttpResponse noContent() => HttpResponse(204);

  @override
  HttpResponse primaryResource(
          Request<ResourceTarget> request, Resource resource,
          {Iterable<Resource> include}) =>
      HttpResponse(200,
          headers: {'Content-Type': Document.contentType},
          body: jsonEncode(Document(
              ResourceData(_resource(resource),
                  links: {'self': Link(_self(request))}),
              included:
                  request.isCompound ? (include ?? []).map(_resource) : null)));

  @override
  HttpResponse createdResource(
          Request<CollectionTarget> request, Resource resource) =>
      HttpResponse(201,
          headers: {
            'Content-Type': Document.contentType,
            'Location': _uri.resource(resource.type, resource.id).toString()
          },
          body: jsonEncode(Document(ResourceData(_resource(resource), links: {
            'self': Link(_uri.resource(resource.type, resource.id))
          }))));

  @override
  HttpResponse primaryCollection(
          Request<CollectionTarget> request, Collection<Resource> collection,
          {Iterable<Resource> include}) =>
      HttpResponse(200,
          headers: {'Content-Type': Document.contentType},
          body: jsonEncode(Document(
              ResourceCollectionData(
                collection.elements.map(_resource),
                links: {'self': Link(_self(request))},
              ),
              included:
                  request.isCompound ? (include ?? []).map(_resource) : null)));

  @override
  HttpResponse relatedCollection(
          Request<RelatedTarget> request, Collection<Resource> collection,
          {List<Resource> include}) =>
      HttpResponse(200,
          headers: {'Content-Type': Document.contentType},
          body: jsonEncode(Document(
              ResourceCollectionData(collection.elements.map(_resource),
                  links: {
                    'self': Link(_self(request)),
                    'related': Link(_uri.related(request.target.type,
                        request.target.id, request.target.relationship))
                  }),
              included:
                  request.isCompound ? (include ?? []).map(_resource) : null)));

  @override
  HttpResponse relatedResource(
          Request<RelatedTarget> request, Resource resource,
          {Iterable<Resource> include}) =>
      HttpResponse(200,
          headers: {'Content-Type': Document.contentType},
          body: jsonEncode(Document(
              ResourceData(_resource(resource), links: {
                'self': Link(_self(request)),
                'related': Link(_uri.related(request.target.type,
                    request.target.id, request.target.relationship))
              }),
              included:
                  request.isCompound ? (include ?? []).map(_resource) : null)));

  @override
  HttpResponse relationshipToMany(Request<RelationshipTarget> request,
          Iterable<Identifier> identifiers) =>
      HttpResponse(200,
          headers: {'Content-Type': Document.contentType},
          body: jsonEncode(Document(ToMany(
            identifiers.map(IdentifierObject.fromIdentifier),
            links: {
              'self': Link(_self(request)),
              'related': Link(_uri.related(request.target.type,
                  request.target.id, request.target.relationship))
            },
          ))));

  @override
  HttpResponse relationshipToOne(
          Request<RelationshipTarget> request, Identifier identifier) =>
      HttpResponse(200,
          headers: {'Content-Type': Document.contentType},
          body: jsonEncode(Document(ToOne(
            IdentifierObject.fromIdentifier(identifier),
            links: {
              'self': Link(_self(request)),
              'related': Link(_uri.related(request.target.type,
                  request.target.id, request.target.relationship))
            },
          ))));

  ResourceObject _resource(Resource resource) =>
      ResourceObject(resource.type, resource.id,
          attributes: resource.attributes,
          relationships: {
            ...resource.toOne.map((k, v) => MapEntry(
                k,
                ToOne(nullable(IdentifierObject.fromIdentifier)(v), links: {
                  'self':
                      Link(_uri.relationship(resource.type, resource.id, k)),
                  'related': Link(_uri.related(resource.type, resource.id, k)),
                }))),
            ...resource.toMany.map((k, v) => MapEntry(
                k,
                ToMany(v.map(IdentifierObject.fromIdentifier), links: {
                  'self':
                      Link(_uri.relationship(resource.type, resource.id, k)),
                  'related': Link(_uri.related(resource.type, resource.id, k)),
                }))),
          },
          links: {
            'self': Link(_uri.resource(resource.type, resource.id))
          });

  Uri _self(Request r) => r.uri.queryParametersAll.isNotEmpty
      ? r.target.link(_uri).replace(queryParameters: r.uri.queryParametersAll)
      : r.target.link(_uri);
}
