import 'package:json_api/src/target.dart';

/// Determines if a given URI matches a specific target
abstract class TargetMatcher {
  /// Matches the target of the [uri]. If the target can be determined,
  /// the corresponding method of [mapper] will be called with the target parameters
  /// and the result will be returned.
  /// Otherwise returns null.
  T matchAndMap<T>(Uri uri, TargetMapper<T> mapper);
}

abstract class TargetMapper<T> {
  T collection(CollectionTarget target);

  T resource(ResourceTarget target);

  T relationship(RelationshipTarget target);

  T related(RelationshipTarget target);

  T unmatched();
}
