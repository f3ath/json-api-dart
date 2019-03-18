import 'package:json_api/document.dart';
import 'package:json_api/src/document/pagination.dart';

class JsonApiDocumentParser {
  const JsonApiDocumentParser();

  Document<Data> parseDocument<Data extends PrimaryData>(
      Object json, Data parsePrimaryData(Object json)) {
    if (json is Map) {
      // TODO: validate `meta`
      if (json.containsKey('errors')) {
        final errors = json['errors'];
        if (errors is List) {
          return Document.error(errors.map(parseError), meta: json['meta']);
        }
      } else if (json.containsKey('data')) {
        return Document(parsePrimaryData(json), meta: json['meta']);
      } else {
        return Document.empty(json['meta']);
      }
    }
    throw 'Can not parse Document from $json';
  }

  JsonApiError parseError(Object json) {
    if (json is Map) {
      Link about;
      if (json['links'] is Map) about = parseLink(json['links']['about']);

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
    throw 'Can not parse ErrorObject from $json';
  }

  /// Parses a JSON:API Document or the `relationship` member of a Resource object.
  Relationship parseRelationship(Object json) {
    if (json is Map) {
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data == null || data is Map) {
          return parseToOne(json);
        }
        if (data is List) {
          return parseToMany(json);
        }
      } else {
        final links = parseLinks(json['links']);
        return Relationship(self: links['self'], related: links['related']);
      }
    }
    throw 'Can not parse Relationship from $json';
  }

  /// Parses the `relationships` member of a Resource Object
  Map<String, Relationship> parseRelationships(Object json) {
    if (json == null) return {};
    if (json is Map) {
      return json.map((k, v) => MapEntry(k.toString(), parseRelationship(v)));
    }
    throw 'Can not parse Relationship map from $json';
  }

  /// Parses the `data` member of a JSON:API Document
  ResourceJson parseResourceJson(Object json) {
    final mapOrNull = (_) => _ == null || _ is Map;
    if (json is Map) {
      final relationships = json['relationships'];
      final attributes = json['attributes'];
      final links = parseLinks(json['links']);

      if (mapOrNull(relationships) && mapOrNull(attributes)) {
        return ResourceJson(json['type'], json['id'],
            attributes: attributes,
            relationships: parseRelationships(relationships),
            self: links['self']);
      }
    }
    throw 'Can not parse ResourceObject from $json';
  }

  /// Parse the document
  ResourceData parseResourceData(Object json) {
    if (json is Map) {
      final links = parseLinks(json['links']);
      final included = json['included'];
      final resources = <ResourceJson>[];
      if (included is List) {
        resources.addAll(included.map(parseResourceJson));
      }
      final data = parseResourceJson(json['data']);
      return ResourceData(data,
          self: links['self'],
          included: resources.isNotEmpty ? resources : null);
    }
    throw 'Can not parse SingleResourceObject from $json';
  }

  /// Parse the document
  ResourceCollectionData parseResourceCollectionData(Object json) {
    if (json is Map) {
      final links = parseLinks(json['links']);
      final included = json['included'];
      final resources = <ResourceJson>[];
      if (included is List) {
        resources.addAll(included.map(parseResourceJson));
      }
      final data = json['data'];
      if (data is List) {
        return ResourceCollectionData(data.map(parseResourceJson),
            self: links['self'],
            pagination: Pagination.fromLinks(links),
            included: resources.isNotEmpty ? resources : null);
      }
    }
    throw 'Can not parse ResourceObjectCollection from $json';
  }

  ToOne parseToOne(Object json) {
    if (json is Map) {
      final links = parseLinks(json['links']);
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data == null) {
          return ToOne.empty(self: links['self'], related: links['related']);
        }
        if (data is Map) {
          return ToOne(parseIdentifierJson(data),
              self: links['self'], related: links['related']);
        }
      }
    }
    throw 'Can not parse ToOne from $json';
  }

  ToMany parseToMany(Object json) {
    if (json is Map) {
      final links = parseLinks(json['links']);
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data is List) {
          return ToMany(data.map(parseIdentifierJson),
              self: links['self'], related: links['related']);
        }
      }
    }
    throw 'Can not parse ToMany from $json';
  }

  IdentifierJson parseIdentifierJson(Object json) {
    if (json is Map) {
      return IdentifierJson(json['type'], json['id']);
    }
    throw 'Can not parse IdentifierObject from $json';
  }

  Link parseLink(Object json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      return LinkObject(Uri.parse(json['href']), meta: json['meta']);
    }
    throw 'Can not parse Link from $json';
  }

  /// Parses the document's `links` member into a map.
  /// The retuning map does not have null values.
  ///
  /// Details on the `links` member: https://jsonapi.org/format/#document-links
  Map<String, Link> parseLinks(Object json) {
    if (json == null) return {};
    if (json is Map) {
      return (json..removeWhere((_, v) => v == null))
          .map((k, v) => MapEntry(k.toString(), parseLink(v)));
    }
    throw 'Can not parse links from $json';
  }
}
