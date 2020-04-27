import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/http/http_method.dart';

/// A JSON:API request.
class Request<D extends PrimaryData> {
  Request(this.method, this.decoder, {QueryParameters parameters})
      : headers = const {'Accept': Document.contentType},
        body = '',
        parameters = parameters ?? QueryParameters.empty();

  Request.withPayload(Document document, this.method, this.decoder,
      {QueryParameters parameters})
      : headers = const {
          'Accept': Document.contentType,
          'Content-Type': Document.contentType
        },
        body = jsonEncode(document),
        parameters = parameters ?? QueryParameters.empty();

  static Request<ResourceCollectionData> fetchCollection(
          {QueryParameters parameters}) =>
      Request(HttpMethod.GET, ResourceCollectionData.fromJson,
          parameters: parameters);

  static Request<ResourceData> fetchResource({QueryParameters parameters}) =>
      Request(HttpMethod.GET, ResourceData.fromJson, parameters: parameters);

  static Request<ToOneObject> fetchToOne({QueryParameters parameters}) =>
      Request(HttpMethod.GET, ToOneObject.fromJson, parameters: parameters);

  static Request<ToManyObject> fetchToMany({QueryParameters parameters}) =>
      Request(HttpMethod.GET, ToManyObject.fromJson, parameters: parameters);

  static Request<RelationshipObject> fetchRelationship(
          {QueryParameters parameters}) =>
      Request(HttpMethod.GET, RelationshipObject.fromJson, parameters: parameters);

  static Request<ResourceData> createResource(
          Document<ResourceData> document) =>
      Request.withPayload(document, HttpMethod.POST, ResourceData.fromJson);

  static Request<ResourceData> updateResource(
          Document<ResourceData> document) =>
      Request.withPayload(document, HttpMethod.PATCH, ResourceData.fromJson);

  static Request<ResourceData> deleteResource() =>
      Request(HttpMethod.DELETE, ResourceData.fromJson);

  static Request<ToOneObject> replaceToOne(Document<ToOneObject> document) =>
      Request.withPayload(document, HttpMethod.PATCH, ToOneObject.fromJson);

  static Request<ToManyObject> deleteFromToMany(Document<ToManyObject> document) =>
      Request.withPayload(document, HttpMethod.DELETE, ToManyObject.fromJson);

  static Request<ToManyObject> replaceToMany(Document<ToManyObject> document) =>
      Request.withPayload(document, HttpMethod.PATCH, ToManyObject.fromJson);

  static Request<ToManyObject> addToMany(Document<ToManyObject> document) =>
      Request.withPayload(document, HttpMethod.POST, ToManyObject.fromJson);

  final PrimaryDataDecoder<D> decoder;
  final String method;
  final String body;
  final Map<String, String> headers;
  final QueryParameters parameters;
}
