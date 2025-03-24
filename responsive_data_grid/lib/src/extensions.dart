part of responsive_data_grid;

extension OrderCriteriaExtensions on List<OrderCriteria> {
  String toOdata() {
    if (this.isEmpty) return "";
    return this.map((e) {
      if (e.direction == OrderDirections.descending) {
        return "${e.fieldName} desc";
      } else {
        return e.fieldName;
      }
    }).join(", ");
  }
}

extension FilterCriteriaExtensions on List<FilterCriteria<dynamic>> {
  String toOdata() {
    if (this.isEmpty) return "";

    String filter = '';
    this.forEach((e) {
      if (filter.isNotEmpty) {
        if (e.op == Operators.or) {
          filter += " OR ";
        } else {
          filter += " AND ";
        }
      }

      if (e.logicalOperator == Logic.endsWidth) {
        filter +=
            " endsWidth(${escapeFieldName(e.fieldName)}, '${e.values.first}')";
      } else if (e.logicalOperator == Logic.contains) {
        filter +=
            " contains(${escapeFieldName(e.fieldName)}, '${e.values.first}')";
      } else if (e.logicalOperator == Logic.notContains) {
        filter +=
            " not contains(${escapeFieldName(e.fieldName)}, '${e.values.first}')";
      } else if (e.logicalOperator == Logic.startsWith) {
        filter +=
            " startsWith(${escapeFieldName(e.fieldName)}, '${e.values.first}')";
      } else if (e.logicalOperator == Logic.between) {
        filter += " ge ${e.values.first} and le ${e.values.last}";
      } else {
        filter += "${escapeFieldName(e.fieldName)} ";
        switch (e.logicalOperator) {
          case Logic.equals:
            filter += "eq";
            break;
          case Logic.greaterThan:
            filter += "gt";
            break;
          case Logic.greaterThanOrEqualTo:
            filter += "ge";
            break;
          case Logic.lessThan:
            filter += "lt";
            break;
          case Logic.lessThanOrEqualTo:
            filter += "le";
            break;
          default:
            throw UnimplementedError();
        }
        filter += " ${e.values.first}";
      }
    });

    return filter;
  }

  String escapeFieldName(String fieldName) => fieldName.replaceAll("'", "''");
}

extension TimeOfDayExtensions on TimeOfDay {
  DateTime toDateTime() {
    final now = new DateTime.now();
    return new DateTime(
      now.year,
      now.month,
      now.day,
      this.hour,
      this.minute,
    );
  }
}
