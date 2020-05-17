import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/request.dart';

class ResponseFactory {
  ResponseFactory(this._uri);

  final UriFactory _uri;

  HttpResponse error(int status,
          {Iterable<ErrorObject> errors, Map<String, String> headers}) =>
      HttpResponse(status,
          body: jsonEncode(Document.error(errors ?? [])),
          headers: {...(headers ?? {}), 'Content-Type': Document.contentType});

  HttpResponse noContent() => HttpResponse(204);

  HttpResponse accepted(Resource resource) => HttpResponse(202,
      headers: {
        'Content-Type': Document.contentType,
        'Content-Location': _uri.resource(resource.type, resource.id).toString()
      },
      body: jsonEncode(Document(ResourceData(_resource(resource),
          links: {'self': Link(_uri.resource(resource.type, resource.id))}))));

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

  HttpResponse relatedResource(
          Request<RelatedTarget> request, Resource resource,
          {Iterable<Resource> include}) =>
      HttpResponse(200,
          headers: {'Content-Type': Document.contentType},
          body: jsonEncode(Document(
              ResourceData(nullable(_resource)(resource), links: {
                'self': Link(_self(request)),
                'related': Link(_uri.related(request.target.type,
                    request.target.id, request.target.relationship))
              }),
              included:
                  request.isCompound ? (include ?? []).map(_resource) : null)));

  HttpResponse relationshipToMany(Request<RelationshipTarget> request,
          Iterable<Identifier> identifiers) =>
      HttpResponse(200,
          headers: {'Content-Type': Document.contentType},
          body: jsonEncode(Document(ToManyObject(
            identifiers,
            links: {
              'self': Link(_self(request)),
              'related': Link(_uri.related(request.target.type,
                  request.target.id, request.target.relationship))
            },
          ))));

  HttpResponse relationshipToOne(
          Request<RelationshipTarget> request, Identifier identifier) =>
      HttpResponse(200,
          headers: {'Content-Type': Document.contentType},
          body: jsonEncode(Document(ToOneObject(
            identifier,
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
            ...resource.relationships.map((k, v) => MapEntry(
                k,
                v
                  ..links['self'] =
                      Link(_uri.relationship(resource.type, resource.id, k))
                  ..links['related'] =
                      Link(_uri.related(resource.type, resource.id, k))))
          },
          links: {
            'self': Link(_uri.resource(resource.type, resource.id))
          });

  Uri _self(Request r) => r.uri.queryParametersAll.isNotEmpty
      ? r.target.link(_uri).replace(queryParameters: r.uri.queryParametersAll)
      : r.target.link(_uri);
}
