import 'package:json_api/src/url_design/target_matcher.dart';
import 'package:json_api/src/url_design/url_factory.dart';

/// URL Design describes how the endpoints are organized.
abstract class UrlDesign implements TargetMatcher, UrlFactory {}
