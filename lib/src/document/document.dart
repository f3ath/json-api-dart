class Document {
  final meta = <String, Object>{};

  Document({Map<String, Object> meta}) {
    this.meta.addAll(meta ?? {});
  }
}
