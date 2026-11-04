part of '../responsive_data_grid.dart';

class ResponseCache<TItem extends Object> {
  final _onCleared = StreamController<void>.broadcast();

  int totalCount = 0;
  Map<int, ListResponse<TItem>> pageMap = {};
  List<GroupResult> groups = List<GroupResult>.empty(growable: true);
  List<AggregateResult> aggregates = List<AggregateResult>.empty(
    growable: true,
  );

  List<TItem> _items = [];

  List<TItem> get items => _items;

  List<TItem> getGroupItems(
    Map<GroupResult, String?> groups,
    List<GridColumn<TItem, dynamic>> columns,
  ) {
    List<TItem> result = _items;
    groups.forEach((g, val) {
      final col = columns
          .where((e) => e.fieldName == g.fieldName)
          .firstOrDefault();
      if (col == null) {
        throw UnsupportedError(
          "The group must reference the same field name as a column.",
        );
      }

      result = result
          .where((e) => gridMatchesGroupValue(col.value(e), val))
          .toList();
    });

    return result;
  }

  void clear() {
    totalCount = 0;
    pageMap.clear();
    groups.clear();
    aggregates.clear();
    _items.clear();
    _onCleared.add(null);
  }

  /// Drops every cached page except [keepPage] after a filter/sort refresh
  /// replaces that page under a loading scrim (#135). Fires [onCleared] when
  /// any other page was removed so infinite-scroll controllers reset.
  void dropPagesExcept(int keepPage) {
    final removed = pageMap.keys.where((k) => k != keepPage).toList();
    if (removed.isEmpty) {
      return;
    }
    for (final key in removed) {
      pageMap.remove(key);
    }
    _items = pageMap.values.expand<TItem>((e) => e.items).toList();
    _onCleared.add(null);
  }

  void dispose() {
    _onCleared.close();
  }

  Stream<void> get onCleared => _onCleared.stream;

  void addPage(ListResponse<TItem> response, int pageNumber) {
    totalCount = response.totalCount;

    if (pageMap.containsKey(pageNumber)) {
      pageMap[pageNumber] = response;
    } else {
      pageMap.addEntries({pageNumber: response}.entries);
    }

    for (var g in response.groups) {
      final existing = groups
          .where((e) => e.fieldName == g.fieldName)
          .firstOrDefault();
      if (existing == null) {
        groups.add(g);
      } else {
        groups[groups.indexOf(existing)] = g;
      }
    }

    for (var agg in response.aggregates) {
      final existing = aggregates
          .where(
            (a) =>
                a.fieldName == agg.fieldName &&
                a.aggregation == agg.aggregation,
          )
          .firstOrDefault();
      if (existing != null) {
        aggregates[aggregates.indexOf(existing)] = agg;
      } else {
        aggregates.add(agg);
      }
    }

    _items = pageMap.values.expand<TItem>((e) => e.items).toList();
  }
}
