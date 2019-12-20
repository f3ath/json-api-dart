class HttpMethod {
  final String _name;

  HttpMethod(String name) : _name = name.toUpperCase();

  bool isPost() => _name == 'POST';

  bool isGet() => _name == 'GET';

  bool isPatch() => _name == 'PATCH';

  bool isDelete() => _name == 'DELETE';
}
