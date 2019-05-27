import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_collection_data.dart';
import 'package:json_api/src/document/resource_data.dart';
import 'package:json_api/src/document/resource_object.dart';
import 'package:json_api/src/validation/naming.dart';
import 'package:json_api/src/validation/standard_naming.dart';

/// Validates document structure and member names
class DocumentValidator {
  final Naming naming;

  DocumentValidator([this.naming = const StandardNaming()]);

  /// Finds issues in the [document].
  /// The document is valid if the returned list is empty.
  List<ValidationError> errors(Document<PrimaryData> document) {
    final errors = <ValidationError>[];

    errors.addAll((document.errors ?? []).asMap().entries.expand((_) =>
        (_.value.meta ?? {}).keys.where(naming.disallows).map((key) =>
            ValidationError('Invalid member name "$key"',
                ['errors', _.key.toString(), 'meta']))));

    errors.addAll((document.meta ?? {})
        .keys
        .where(naming.disallows)
        .map((key) => ValidationError('Invalid member name "$key"', ['meta'])));

    final data = document.data;

    if (data != null) {
      errors.addAll(_dataErrors(data));
    }

    return errors;
  }

  Iterable<ValidationError> _dataErrors(PrimaryData data) {
    final errors = <ValidationError>[];

    final included = Set<String>();

    errors.addAll((data.included ?? [])
        .map((_) => _.toResource())
        .where((_) => !included.add("${_.type}:${_.id}"))
        .map((_) =>
            ValidationError('$_ is included multiple times', ['included'])));

    if (data is ResourceData) {
      if ((data.included ?? []).any((_) => _
          .toResource()
          .toIdentifier()
          .equals(data.toResource().toIdentifier()))) {
        errors.add(ValidationError(
            'Primary ${data.toResource()} is also included', ['included']));
      }
      errors.addAll(_resourceErrors(data.resourceObject, path: ['data']));
    }
    if (data is ResourceCollectionData) {
      // TODO: implement collection validation
    }
    if (data is ToOne) {
      // TODO: implement to-one validation
    }
    if (data is ToMany) {
      // TODO: implement to-many validation
    }
    return errors;
  }

  Iterable<ValidationError> _resourceErrors(ResourceObject resourceObject,
      {List<String> path = const []}) {
    const reserved = ['type', 'id'];
    return reserved
        .where((resourceObject.attributes ?? {}).containsKey)
        .map((_) => ValidationError('Invalid name "$_"', path + ['attributes']))
        .followedBy(reserved
            .where((resourceObject.relationships ?? {}).containsKey)
            .map((_) =>
                ValidationError('Invalid name "$_"', path + ['relationships'])))
        .followedBy(Set.of((resourceObject.attributes ?? {}).keys)
            .intersection(Set.of((resourceObject.relationships ?? {}).keys))
            .map((_) => ValidationError(
                'Name "$_" is used in both attributes and relationships',
                path)));
  }
}

class ValidationError {
  final String message;
  final String path;

  ValidationError(this.message, Iterable<String> path)
      : path = '/' + path.join('/');
}
