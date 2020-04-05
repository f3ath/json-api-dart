import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/collection.dart';

abstract class ControllerResponse {
  HttpResponse convert();
}

class ErrorResponse implements ControllerResponse {
  ErrorResponse(this.status, this.errors, {this.headers = const {}});

  final int status;
  final Map<String, String> headers;
  final List<ErrorObject> errors;

  @override
  HttpResponse convert() => HttpResponse(status,
      body: jsonEncode(Document.error(errors)), headers: headers);
}

class NoContentResponse implements ControllerResponse {
  @override
  HttpResponse convert() => HttpResponse(204);
}

class ResourceResponse implements ControllerResponse {
  ResourceResponse(this.resource, {this.include});

  final Resource resource;
  final List<Resource> include;

  @override
  HttpResponse convert() {
    return HttpResponse(200,
        body: jsonEncode(Document(ResourceData(_resourceObject(resource),
            include: include?.map(_resourceObject)))));
  }
}

class CreatedResourceResponse implements ControllerResponse {
  CreatedResourceResponse(this.resource);

  final Resource resource;

  @override
  HttpResponse convert() {
    return HttpResponse(201,
        body: jsonEncode(Document(ResourceData(_resourceObject(resource,
            self: Link(
                StandardRouting().resource(resource.type, resource.id)))))),
        headers: {
          'Location':
              StandardRouting().resource(resource.type, resource.id).toString()
        });
  }
}

class CollectionResponse implements ControllerResponse {
  CollectionResponse(this.collection, {this.include});

  final Collection<Resource> collection;
  final List<Resource> include;

  @override
  HttpResponse convert() {
    return HttpResponse(200,
        body: jsonEncode(Document(ResourceCollectionData(
            collection.elements.map(_resourceObject),
            include: include?.map(_resourceObject)))));
  }
}

class ToOneResponse implements ControllerResponse {
  ToOneResponse(this.identifier);

  final Identifier identifier;

  @override
  HttpResponse convert() {
    return HttpResponse(200,
        body: jsonEncode(
            Document(ToOne(IdentifierObject.fromIdentifier(identifier)))));
  }
}

class ToManyResponse implements ControllerResponse {
  ToManyResponse(this.identifiers);

  final List<Identifier> identifiers;

  @override
  HttpResponse convert() {
    return HttpResponse(200,
        body: jsonEncode(Document(
            ToMany(identifiers.map(IdentifierObject.fromIdentifier)))));
  }
}

ResourceObject _resourceObject(Resource resource, {Link self}) {
  return ResourceObject(resource.type, resource.id,
      attributes: resource.attributes,
      relationships: {
        ...resource.toOne.map((k, v) =>
            MapEntry(k, ToOne(nullable(IdentifierObject.fromIdentifier)(v)))),
        ...resource.toMany.map((k, v) =>
            MapEntry(k, ToMany(v.map(IdentifierObject.fromIdentifier)))),
      },
      links: {
        if (self != null) 'self': self
      });
}
