# Implementation of [{json:api} v1.0](http://jsonapi.org) in Dart
[{json:api} v1.0](http://jsonapi.org) is a specification for building APIs in JSON. This library implements 
a Client (VM, Flutter, Web), and a Server (VM only).


## Client
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
- [x] Related collection pagination
- [x] Asynchronous processing 

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
- [x] Related collection pagination
- [x] Compound documents
- [x] Asynchronous processing 

#### Document
- [x] Support relationship objects lacking the `data` member
- [x] Compound documents
- [ ] Support `meta` members
- [ ] Support `jsonapi` members
- [ ] Structural Validation including compound documents and sparse fieldsets
- [ ] Naming Validation
- [ ] Meaningful parsing exceptions
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