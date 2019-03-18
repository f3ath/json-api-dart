import 'package:json_api/document.dart';
import 'package:json_api/src/document/pagination.dart';

class ParserException implements Exception {
  final String message;

  ParserException(this.message);
}

class JsonApiParser {
  const JsonApiParser();

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
    throw ParserException('Can not parse Document from $json');
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
    throw ParserException('Can not parse ErrorObject from $json');
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
    throw ParserException('Can not parse Relationship from $json');
  }

  /// Parses the `relationships` member of a Resource Object
  Map<String, Relationship> parseRelationships(Object json) {
    if (json == null) return {};
    if (json is Map) {
      return json.map((k, v) => MapEntry(k.toString(), parseRelationship(v)));
    }
    throw ParserException('Can not parse Relationship map from $json');
  }

  /// Parses the `data` member of a JSON:API Document
  ResourceObject parseResourceObject(Object json) {
    final mapOrNull = (_) => _ == null || _ is Map;
    if (json is Map) {
      final relationships = json['relationships'];
      final attributes = json['attributes'];
      final links = parseLinks(json['links']);

      if (mapOrNull(relationships) && mapOrNull(attributes)) {
        return ResourceObject(json['type'], json['id'],
            attributes: attributes,
            relationships: parseRelationships(relationships),
            self: links['self']);
      }
    }
    throw ParserException('Can not parse ResourceObject from $json');
  }

  /// Parse the document
  ResourceData parseResourceData(Object json) {
    if (json is Map) {
      final links = parseLinks(json['links']);
      final included = json['included'];
      final resources = <ResourceObject>[];
      if (included is List) {
        resources.addAll(included.map(parseResourceObject));
      }
      final data = parseResourceObject(json['data']);
      return ResourceData(data,
          self: links['self'],
          included: resources.isNotEmpty ? resources : null);
    }
    throw ParserException('Can not parse SingleResourceObject from $json');
  }

  /// Parse the document
  ResourceCollectionData parseResourceCollectionData(Object json) {
    if (json is Map) {
      final links = parseLinks(json['links']);
      final included = json['included'];
      final resources = <ResourceObject>[];
      if (included is List) {
        resources.addAll(included.map(parseResourceObject));
      }
      final data = json['data'];
      if (data is List) {
        return ResourceCollectionData(data.map(parseResourceObject),
            self: links['self'],
            pagination: Pagination.fromLinks(links),
            included: resources.isNotEmpty ? resources : null);
      }
    }
    throw ParserException('Can not parse ResourceObjectCollection from $json');
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
          return ToOne(parseIdentifierObject(data),
              self: links['self'], related: links['related']);
        }
      }
    }
    throw ParserException('Can not parse ToOne from $json');
  }

  ToMany parseToMany(Object json) {
    if (json is Map) {
      final links = parseLinks(json['links']);
      if (json.containsKey('data')) {
        final data = json['data'];
        if (data is List) {
          return ToMany(data.map(parseIdentifierObject),
              self: links['self'], related: links['related']);
        }
      }
    }
    throw ParserException('Can not parse ToMany from $json');
  }

  IdentifierObject parseIdentifierObject(Object json) {
    if (json is Map) {
      return IdentifierObject(json['type'], json['id']);
    }
    throw ParserException('Can not parse IdentifierObject from $json');
  }

  Link parseLink(Object json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      return LinkObject(Uri.parse(json['href']), meta: json['meta']);
    }
    throw ParserException('Can not parse Link from $json');
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
    throw ParserException('Can not parse links from $json');
  }
}
