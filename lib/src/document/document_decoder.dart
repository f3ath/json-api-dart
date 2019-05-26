import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/error.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/json_api.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_collection_data.dart';
import 'package:json_api/src/document/resource_data.dart';
import 'package:json_api/src/document/resource_object.dart';

class ParsingException implements Exception {
  final String message;

  ParsingException(this.message);
}

class JsonApiDecoder {
  const JsonApiDecoder();

  /// Parses a document containing neither data nor errors
  Document<ToOne> decodeEmptyDocument(Object json) =>
      decodeDocument(json, null);

  /// Parses a document containing a single resource
  Document<ResourceData> decodeResourceDocument(Object json) =>
      decodeDocument(json, decodeResourceData);

  /// Parses a document containing a resource collection
  Document<ResourceCollectionData> decodeResourceCollectionDocument(
          Object json) =>
      decodeDocument(json, decodeResourceCollectionData);

  /// Parses a document containing a to-one relationship
  Document<ToOne> decodeToOneDocument(Object json) =>
      decodeDocument(json, decodeToOne);

  /// Parses a document containing a to-many relationship
  Document<ToMany> decodeToManyDocument(Object json) =>
      decodeDocument(json, decodeToMany);

  /// Parses a document with the specified primary data
  Document<Data> decodeDocument<Data extends PrimaryData>(
      Object json, Data decodePrimaryData(Object json)) {
    if (json is Map) {
      JsonApi api;
      if (json.containsKey('jsonapi')) {
        api = decodeJsonApi(json['jsonapi']);
      }
      if (json.containsKey('errors')) {
        final errors = json['errors'];
        if (errors is List) {
          return Document.error(errors.map(decodeError),
              meta: json['meta'], api: api);
        }
      } else if (json.containsKey('data')) {
        return Document(decodePrimaryData(json), meta: json['meta'], api: api);
      } else {
        return Document.empty(json['meta'], api: api);
      }
    }
    throw ParsingException('Can not decode Document from $json');
  }

  JsonApiError decodeError(Object json) {
    if (json is Map) {
      Link about;
      if (json['links'] is Map) about = decodeLink(json['links']['about']);

      String pointer;
      String parameter;
      if (json['source'] is Map) {
        parameter = json['source']['parameter'];
        pointer = json['source']['pointer'];
      }
      return JsonApiError(
          id: json['id'],
          about: about,
          status: json['status'],
          code: json['code'],
          title: json['title'],
          detail: json['detail'],
          sourcePointer: pointer,
          sourceParameter: parameter,
          meta: json['meta']);
    }
    throw ParsingException('Can not decode ErrorObject from $json');
  }

  /// Parses a JSON:API Document or the `relationship` member of a Resource object.
  Relationship decodeRelationship(Object json) {
    if (json is Map) {
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data == null || data is Map) {
          return decodeToOne(json);
        }
        if (data is List) {
          return decodeToMany(json);
        }
      } else {
        final links = decodeLinks(json['links']);
        return Relationship(self: links['self'], related: links['related']);
      }
    }
    throw ParsingException('Can not decode Relationship from $json');
  }

  /// Parses the `relationships` member of a Resource Object
  Map<String, Relationship> decodeRelationships(Object json) {
    if (json == null) return {};
    if (json is Map) {
      return json.map((k, v) => MapEntry(k.toString(), decodeRelationship(v)));
    }
    throw ParsingException('Can not decode Relationship map from $json');
  }

  /// Parses the `data` member of a JSON:API Document
  ResourceObject decodeResourceObject(Object json) {
    final mapOrNull = (_) => _ == null || _ is Map;
    if (json is Map) {
      final relationships = json['relationships'];
      final attributes = json['attributes'];
      final links = decodeLinks(json['links']);

      if (mapOrNull(relationships) && mapOrNull(attributes)) {
        return ResourceObject(json['type'], json['id'],
            attributes: attributes,
            relationships: decodeRelationships(relationships),
            self: links['self']);
      }
    }
    throw ParsingException('Can not decode ResourceObject from $json');
  }

  /// Parse the document
  ResourceData decodeResourceData(Object json) {
    if (json is Map) {
      final links = decodeLinks(json['links']);
      final included = json['included'];
      final resources = <ResourceObject>[];
      if (included is List) {
        resources.addAll(included.map(decodeResourceObject));
      }
      final data = decodeResourceObject(json['data']);
      return ResourceData(data,
          self: links['self'],
          included: resources.isNotEmpty ? resources : null);
    }
    throw ParsingException('Can not decode SingleResourceObject from $json');
  }

  /// Parse the document
  ResourceCollectionData decodeResourceCollectionData(Object json) {
    if (json is Map) {
      final links = decodeLinks(json['links']);
      final included = json['included'];
      final data = json['data'];
      if (data is List) {
        return ResourceCollectionData(data.map(decodeResourceObject),
            self: links['self'],
            pagination: Pagination.fromLinks(links),
            included: included == null ? null : decodeIncluded(included));
      }
    }
    throw ParsingException(
        'Can not decode ResourceObjectCollection from $json');
  }

  ToOne decodeToOne(Object json) {
    if (json is Map) {
      final links = decodeLinks(json['links']);
      final included = json['included'];
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data == null) {
          return ToOne(null,
              self: links['self'],
              related: links['related'],
              included: included == null ? null : decodeIncluded(included));
        }
        if (data is Map) {
          return ToOne(decodeIdentifierObject(data),
              self: links['self'],
              related: links['related'],
              included: included == null ? null : decodeIncluded(included));
        }
      }
    }
    throw ParsingException('Can not decode ToOne from $json');
  }

  ToMany decodeToMany(Object json) {
    if (json is Map) {
      final links = decodeLinks(json['links']);

      if (json.containsKey('data')) {
        final data = json['data'];
        if (data is List) {
          return ToMany(
            data.map(decodeIdentifierObject),
            self: links['self'],
            related: links['related'],
            pagination: Pagination.fromLinks(links),
          );
        }
      }
    }
    throw ParsingException('Can not decode ToMany from $json');
  }

  IdentifierObject decodeIdentifierObject(Object json) {
    if (json is Map) {
      return IdentifierObject(json['type'], json['id'], meta: json['meta']);
    }
    throw ParsingException('Can not decode IdentifierObject from $json');
  }

  Link decodeLink(Object json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      final href = json['href'];
      if (href is String) {
        return LinkObject(Uri.parse(href), meta: json['meta']);
      }
    }
    throw ParsingException('Can not decode Link from $json');
  }

  /// Parses the document's `links` member into a map.
  /// The retuning map does not have null values.
  ///
  /// Details on the `links` member: https://jsonapi.org/format/#document-links
  Map<String, Link> decodeLinks(Object json) {
    if (json == null) return {};
    if (json is Map) {
      return (json..removeWhere((_, v) => v == null))
          .map((k, v) => MapEntry(k.toString(), decodeLink(v)));
    }
    throw ParsingException('Can not decode links from $json');
  }

  JsonApi decodeJsonApi(Object json) {
    if (json is Map) {
      return JsonApi(version: json['version'], meta: json['meta']);
    }
    throw ParsingException('Can not decode JsonApi from $json');
  }

  Iterable<ResourceObject> decodeIncluded(Object json) {
    if (json is List) return json.map(decodeResourceObject);
    throw ParsingException(
        'Can not decode Iterable<ResourceObject> from $json');
  }
}
