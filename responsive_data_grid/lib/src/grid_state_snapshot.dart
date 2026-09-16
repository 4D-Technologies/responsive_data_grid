part of '../responsive_data_grid.dart';

class GridColumnSnapshot {
  final String fieldName;
  final bool visible;
  final bool frozen;
  final bool sticky;
  final double? width;

  const GridColumnSnapshot({
    required this.fieldName,
    this.visible = true,
    this.frozen = false,
    this.sticky = false,
    this.width,
  });

  Map<String, dynamic> toJson() => {
    'fieldName': fieldName,
    'visible': visible,
    'frozen': frozen,
    'sticky': sticky,
    'width': width,
  };

  factory GridColumnSnapshot.fromJson(Map<String, dynamic> json) {
    return GridColumnSnapshot(
      fieldName: json['fieldName'] as String,
      visible: json['visible'] as bool? ?? true,
      frozen: json['frozen'] as bool? ?? false,
      sticky: json['sticky'] as bool? ?? false,
      width: (json['width'] as num?)?.toDouble(),
    );
  }
}

/// Serializable view of sort, filter, groups, page, and column layout.
class GridStateSnapshot {
  final int pageNumber;
  final int pageSize;
  final LoadCriteria criteria;
  final List<GridColumnSnapshot> columns;

  const GridStateSnapshot({
    required this.pageNumber,
    required this.pageSize,
    required this.criteria,
    required this.columns,
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    'criteria': criteria.toJson(),
    'columns': columns.map((c) => c.toJson()).toList(),
  };

  factory GridStateSnapshot.fromJson(Map<String, dynamic> json) {
    return GridStateSnapshot(
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 50,
      criteria: json['criteria'] is Map<String, dynamic>
          ? LoadCriteria.fromJson(json['criteria'] as Map<String, dynamic>)
          : LoadCriteria(),
      columns: [
        for (final raw in (json['columns'] as List<dynamic>? ?? const []))
          GridColumnSnapshot.fromJson(Map<String, dynamic>.from(raw as Map)),
      ],
    );
  }
}
