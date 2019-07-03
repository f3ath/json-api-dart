class Include {
  final resources = <String>[];

  Include(List<String> resources) {
    this.resources.addAll(resources);
  }

  factory Include.decode(Map<String, List<String>> query) {
    final resources = query['include'].expand((_) => _.split(',')).toList();
    return Include(resources);
  }

  get length => resources.length;
}
