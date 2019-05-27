abstract class Page {
  int get limit;

  int get offset;

  Uri addTo(Uri uri);

  Page first();

  Page last(int total);

  Page prev();

  Page next(int total);
}

typedef Page PageFactory(Map<String, List<String>> query);
