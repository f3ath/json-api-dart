import 'package:json_api/src/url_design/target_mapper.dart';

/// Determines if a given URI matches a specific target
abstract class TargetMatcher {
  /// Matches the target of the [uri]. If the target can be determined,
  /// the corresponding method of [mapper] will be called with the target parameters
  /// and the result will be returned.
  /// Otherwise returns the result of [TargetMapper.unmatched].
  T matchAndMap<T>(Uri uri, TargetMapper<T> mapper);
}
