import 'package:intl/intl.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

enum ExampleEnum { one, two, three }

class ExampleData {
  final int id;
  final String name;
  final DateTime dob;
  final bool accepted;
  final ExampleEnum exampleEnum;
  final String team;

  const ExampleData(
    this.id,
    this.name,
    this.dob,
    this.accepted,
    this.exampleEnum, {
    this.team = 'A',
  });
}

List<ExampleData> exampleRows([int count = 80]) {
  const names = ['John Doe', 'Jane Doe', 'Ada Lovelace', 'Grace Hopper'];
  return [
    for (var i = 1; i <= count; i++)
      ExampleData(
        i,
        names[i % names.length],
        DateTime(1970 + (i % 30), (i % 12) + 1, (i % 27) + 1),
        i.isEven,
        ExampleEnum.values[i % ExampleEnum.values.length],
        team: i % 3 == 0 ? 'Ops' : (i.isEven ? 'Field' : 'Admin'),
      ),
  ];
}

List<GridColumn<ExampleData, dynamic>> exampleColumns() {
  return [
    IntColumn(
      xsCols: 2,
      fieldName: 'id',
      header: const ColumnHeader(
        text: 'Id',
        showFilter: true,
        showOrderBy: true,
      ),
      value: (row) => row.id,
    ),
    StringColumn(
      xsCols: 4,
      fieldName: 'name',
      header: const ColumnHeader(
        text: 'Name',
        showFilter: true,
        showOrderBy: true,
      ),
      value: (row) => row.name,
    ),
    StringColumn(
      xsCols: 3,
      fieldName: 'team',
      header: const ColumnHeader(
        text: 'Team',
        showFilter: true,
        showOrderBy: true,
      ),
      value: (row) => row.team,
    ),
    DateTimeColumn(
      xsCols: 3,
      fieldName: 'dob',
      filterRules: DateTimeFilterRules(
        filterType: DateTimeFilterTypes.DateOnly,
      ),
      header: const ColumnHeader(
        text: 'Date of Birth',
        showFilter: true,
        showOrderBy: true,
      ),
      value: (row) => row.dob,
      format: DateFormat.yMd(),
    ),
  ];
}
