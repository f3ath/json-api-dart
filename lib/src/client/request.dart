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

  static Request<ToOne> fetchToOne({QueryParameters parameters}) =>
      Request(HttpMethod.GET, ToOne.fromJson, parameters: parameters);

  static Request<ToMany> fetchToMany({QueryParameters parameters}) =>
      Request(HttpMethod.GET, ToMany.fromJson, parameters: parameters);

  static Request<Relationship> fetchRelationship(
          {QueryParameters parameters}) =>
      Request(HttpMethod.GET, Relationship.fromJson, parameters: parameters);

  static Request<ResourceData> createResource(
          Document<ResourceData> document) =>
      Request.withPayload(document, HttpMethod.POST, ResourceData.fromJson);

  static Request<ResourceData> updateResource(
          Document<ResourceData> document) =>
      Request.withPayload(document, HttpMethod.PATCH, ResourceData.fromJson);

  static Request<ResourceData> deleteResource() =>
      Request(HttpMethod.DELETE, ResourceData.fromJson);

  static Request<ToOne> replaceToOne(Document<ToOne> document) =>
      Request.withPayload(document, HttpMethod.PATCH, ToOne.fromJson);

  static Request<ToMany> deleteFromToMany(Document<ToMany> document) =>
      Request.withPayload(document, HttpMethod.DELETE, ToMany.fromJson);

  static Request<ToMany> replaceToMany(Document<ToMany> document) =>
      Request.withPayload(document, HttpMethod.PATCH, ToMany.fromJson);

  static Request<ToMany> addToMany(Document<ToMany> document) =>
      Request.withPayload(document, HttpMethod.POST, ToMany.fromJson);

  final PrimaryDataDecoder<D> decoder;
  final String method;
  final String body;
  final Map<String, String> headers;
  final QueryParameters parameters;
}
