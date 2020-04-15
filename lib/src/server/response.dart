import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/target.dart';

abstract class Response {
  int get status;

  Map<String, String> headers(UriFactory factory);

  Document document(DocumentFactory doc, UriFactory factory);
}

class ErrorResponse implements Response {
  ErrorResponse(this.status, this.errors);

  @override
  final int status;
  final List<ErrorObject> errors;

  @override
  Map<String, String> headers(UriFactory factory) =>
      {'Content-Type': Document.contentType};

  @override
  Document document(DocumentFactory doc, UriFactory factory) =>
      doc.error(errors);
}

class ExtraHeaders implements Response {
  ExtraHeaders(this._response, this._headers);

  final Response _response;

  final Map<String, String> _headers;

  @override
  Document<PrimaryData> document(DocumentFactory doc, UriFactory factory) =>
      _response.document(doc, factory);

  @override
  Map<String, String> headers(UriFactory factory) =>
      {..._response.headers(factory), ..._headers};

  @override
  int get status => _response.status;
}

class NoContentResponse implements Response {
  NoContentResponse();

  @override
  int get status => 204;

  @override
  Map<String, String> headers(UriFactory factory) => {};

  @override
  Document document(DocumentFactory doc, UriFactory factory) => null;
}

class PrimaryResourceResponse implements Response {
  PrimaryResourceResponse(this.request, this.resource, {this.include});

  final Request<ResourceTarget> request;

  final Resource resource;
  final List<Resource> include;

  @override
  int get status => 200;

  @override
  Map<String, String> headers(UriFactory factory) =>
      {'Content-Type': Document.contentType};

  @override
  Document<ResourceData> document(DocumentFactory doc, UriFactory factory) =>
      doc.resource(factory, resource,
          include: include, self: request.generateSelfUri(factory));
}

class RelatedResourceResponse implements Response {
  RelatedResourceResponse(this.request, this.resource, {this.include});

  final Request<RelationshipTarget> request;
  final Resource resource;
  final List<Resource> include;

  @override
  int get status => 200;

  @override
  Map<String, String> headers(UriFactory factory) =>
      {'Content-Type': Document.contentType};

  @override
  Document<ResourceData> document(DocumentFactory doc, UriFactory factory) =>
      doc.resource(factory, resource,
          include: include, self: request.generateSelfUri(factory));
}

class CreatedResourceResponse implements Response {
  CreatedResourceResponse(this.resource);

  final Resource resource;

  @override
  int get status => 201;

  @override
  Map<String, String> headers(UriFactory factory) => {
        'Content-Type': Document.contentType,
        'Location': factory.resource(resource.type, resource.id).toString()
      };

  @override
  Document<ResourceData> document(DocumentFactory doc, UriFactory factory) =>
      doc.resource(factory, resource);
}

class PrimaryCollectionResponse implements Response {
  PrimaryCollectionResponse(this.request, this.collection, {this.include});

  final Request<CollectionTarget> request;
  final Collection<Resource> collection;
  final List<Resource> include;

  @override
  int get status => 200;

  @override
  Map<String, String> headers(UriFactory factory) =>
      {'Content-Type': Document.contentType};

  @override
  Document<ResourceCollectionData> document(
          DocumentFactory doc, UriFactory factory) =>
      doc.collection(factory, collection,
          include: include, self: request.generateSelfUri(factory));
}

class RelatedCollectionResponse implements Response {
  RelatedCollectionResponse(this.request, this.collection, {this.include});

  final Request<RelationshipTarget> request;
  final Collection<Resource> collection;
  final List<Resource> include;

  @override
  int get status => 200;

  @override
  Map<String, String> headers(UriFactory factory) =>
      {'Content-Type': Document.contentType};

  @override
  Document<ResourceCollectionData> document(
          DocumentFactory doc, UriFactory factory) =>
      doc.collection(factory, collection,
          include: include, self: request.generateSelfUri(factory));
}

class ToOneResponse implements Response {
  ToOneResponse(this.request, this.identifier);

  final Request<RelationshipTarget> request;

  final Identifier identifier;

  @override
  int get status => 200;

  @override
  Map<String, String> headers(UriFactory factory) =>
      {'Content-Type': Document.contentType};

  @override
  Document<ToOne> document(DocumentFactory doc, UriFactory factory) =>
      doc.toOne(identifier,
          self: request.generateSelfUri(factory),
          related: factory.related(request.target.type, request.target.id,
              request.target.relationship));
}

class ToManyResponse implements Response {
  ToManyResponse(this.request, this.identifiers);

  final Request<RelationshipTarget> request;

  final List<Identifier> identifiers;

  @override
  int get status => 200;

  @override
  Map<String, String> headers(UriFactory factory) =>
      {'Content-Type': Document.contentType};

  @override
  Document<ToMany> document(DocumentFactory doc, UriFactory factory) =>
      doc.toMany(identifiers,
          self: request.generateSelfUri(factory),
          related: factory.related(request.target.type, request.target.id,
              request.target.relationship));
}

class DocumentFactory {
  Document error(List<ErrorObject> errors) => Document.error(errors);

  Document<ResourceCollectionData> collection(
          UriFactory factory, Collection<Resource> collection,
          {List<Resource> include, Uri self}) =>
      Document(ResourceCollectionData(
          collection.elements.map((_) => _resource(factory, _)),
          links: {if (self != null) 'self': Link(self)},
          include: include?.map((_) => _resource(factory, _))));

  Document<ResourceData> resource(UriFactory factory, Resource resource,
          {List<Resource> include, Uri self}) =>
      Document(ResourceData(_resource(factory, resource),
          links: {if (self != null) 'self': Link(self)},
          include: include?.map((_) => _resource(factory, _))));

  Document<ToOne> toOne(Identifier identifier, {Uri self, Uri related}) =>
      Document(ToOne(
        IdentifierObject.fromIdentifier(identifier),
        links: {
          if (self != null) 'self': Link(self),
          if (related != null) 'related': Link(related),
        },
      ));

  Document<ToMany> toMany(List<Identifier> identifiers,
          {Uri self, Uri related}) =>
      Document(ToMany(
        identifiers.map(IdentifierObject.fromIdentifier),
        links: {
          if (self != null) 'self': Link(self),
          if (related != null) 'related': Link(related),
        },
      ));

  ResourceObject _resource(UriFactory factory, Resource resource) =>
      ResourceObject(resource.type, resource.id,
          attributes: resource.attributes,
          relationships: {
            ...resource.toOne.map((k, v) => MapEntry(
                k,
                ToOne(nullable(IdentifierObject.fromIdentifier)(v), links: {
                  'self':
                      Link(factory.relationship(resource.type, resource.id, k)),
                  'related':
                      Link(factory.related(resource.type, resource.id, k)),
                }))),
            ...resource.toMany.map((k, v) => MapEntry(
                k,
                ToMany(v.map(IdentifierObject.fromIdentifier), links: {
                  'self':
                      Link(factory.relationship(resource.type, resource.id, k)),
                  'related':
                      Link(factory.related(resource.type, resource.id, k)),
                }))),
          },
          links: {
            'self': Link(factory.resource(resource.type, resource.id))
          });
}
