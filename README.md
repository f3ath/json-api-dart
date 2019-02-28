# Implementation of [JSON:API v1.0](http://jsonapi.org) in Dart

#### Feature roadmap
##### Client
- [x] Fetching single resources and resource collections
- [x] Fetching relationships and related resources and collections
- [x] Fetching single resources
- [x] Creating resources
- [ ] Updating resource's attributes
- [ ] Updating resource's relationships
- [ ] Updating relationships
- [ ] Deleting resources
- [ ] Asynchronous processing 

##### Server (The Server API is not stable yet!)
- [x] Fetching single resources and resource collections
- [x] Fetching relationships and related resources and collections
- [x] Fetching single resources
- [x] Creating resources
- [ ] Updating resource's attributes
- [ ] Updating resource's relationships
- [ ] Updating relationships
- [ ] Deleting resources
- [ ] Inclusion of related resources 
- [ ] Sparse fieldsets 
- [ ] Sorting, pagination, filtering
- [ ] Asynchronous processing 

##### Document
- [ ] Support `meta` and `jsonapi` members
- [ ] Structure Validation
- [ ] Support relationship objects lacking the `data` member
- [ ] Naming Validation
- [ ] JSON:API v1.1 features

### Usage
In the VM:
```dart
import 'package:json_api/client.dart';

final client = JsonApiClient();
```

In a browser:
```dart
import 'package:json_api/client.dart';
import 'package:http/browser_client.dart';

final client = JsonApiClient(factory: () => BrowserClient());
```

For usage examples see the [functional tests](https://github.com/f3ath/json-api-dart/tree/master/test/functional).