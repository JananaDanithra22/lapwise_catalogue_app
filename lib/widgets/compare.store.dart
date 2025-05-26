

class CompareStore {
  static final CompareStore _instance = CompareStore._internal();
  factory CompareStore() => _instance;
  CompareStore._internal();

  final List<String> _comparedProductIds = [];

  List<String> get comparedProductIds => _comparedProductIds;

  void add(String id) {
    if (!_comparedProductIds.contains(id)) {
      _comparedProductIds.add(id);
    }
  }

  void remove(String id) {
    _comparedProductIds.remove(id);
  }

  void clear() {
    _comparedProductIds.clear();
  }
}
