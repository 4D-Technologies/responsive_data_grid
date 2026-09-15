part of '../responsive_data_grid.dart';

/// Imperative API for a [ResponsiveDataGrid]. Optional; the grid still works
/// without one. Do not use after [dispose].
class ResponsiveDataGridController<TItem extends Object> extends ChangeNotifier {
  ResponsiveDataGridState<TItem>? _client;

  bool get isAttached => _client != null;

  bool get isLoading => _client?.isLoading ?? false;

  int get pageNumber => _client?.pageNumber ?? 1;

  LoadCriteria? get criteria => _client?.criteria;

  void _attach(ResponsiveDataGridState<TItem> state) {
    _client = state;
  }

  void _detach(ResponsiveDataGridState<TItem> state) {
    if (identical(_client, state)) {
      _client = null;
    }
  }

  void _emit() {
    notifyListeners();
  }

  Future<void> refresh() async {
    await _client?.refreshData();
    notifyListeners();
  }

  Future<void> setPage(int pageNumber) async {
    await _client?.setPage(pageNumber);
    notifyListeners();
  }

  Future<void> clearFilters() async {
    await _client?.clearFilters();
    notifyListeners();
  }

  void setColumnVisible(String fieldName, bool visible) {
    _client?.setColumnVisible(fieldName, visible);
    notifyListeners();
  }

  GridStateSnapshot? captureState() => _client?.captureState();

  void restoreState(GridStateSnapshot snapshot) {
    _client?.restoreState(snapshot);
    notifyListeners();
  }

  @override
  void dispose() {
    _client = null;
    super.dispose();
  }
}
