# Implementation of [JSON:API v1.0](http://jsonapi.org) in Dart

## Warning! This is a work-in-progress. While at v0, the API is changing rapidly.

### Feature roadmap
The features here are roughly ordered by priority. Feel free to open an issue if you want to add another feature.

#### Client
- [x] Fetching single resources and resource collections
- [x] Collection pagination
- [x] Fetching relationships and related resources and collections
- [x] Fetching single resources
- [x] Creating resources
- [x] Deleting resources
- [x] Updating resource's attributes
- [x] Updating resource's relationships
- [x] Updating relationships
- [x] Compound documents
- [ ] Related collection pagination
- [ ] Asynchronous processing 
- [ ] Optional check for `Content-Type` header in incoming responses 

#### Server
- [x] Fetching single resources and resource collections
- [x] Collection pagination
- [x] Fetching relationships and related resources and collections
- [x] Fetching single resources
- [x] Creating resources
- [x] Deleting resources
- [x] Updating resource's attributes
- [x] Updating resource's relationships
- [x] Updating relationships
- [ ] Compound documents
- [ ] Sparse fieldsets 
- [ ] Sorting, filtering
- [ ] Related collection pagination
- [ ] Asynchronous processing 
- [ ] Optional check for `Content-Type` header in incoming requests 
- [ ] Support annotations in resource mappers (?) 

#### Document
- [x] Support relationship objects lacking the `data` member
- [x] Compound documents
- [ ] Support `meta` members
- [ ] Support `jsonapi` members
- [ ] Structural Validation including compound documents
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