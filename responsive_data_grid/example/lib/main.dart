import 'package:client_filtering/client_filtering.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_data_grid/responsive_data_grid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        dataTableTheme: Theme.of(context)
            .dataTableTheme
            .copyWith(headingRowColor: WidgetStateProperty.all(Colors.black54)),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final exampleData = List<ExampleData>.from(<ExampleData>[
    ExampleData(1, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(2, "Jane Doe", DateTime(1977, 6, 17), false, ExampleEnum.two),
    ExampleData(3, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(4, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(5, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(6, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(7, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(8, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(9, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(10, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(11, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(12, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(13, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(14, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(15, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(16, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(17, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(18, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(19, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(20, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(21, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(22, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(23, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(24, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(25, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(26, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(27, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(28, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(29, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(30, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(31, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(32, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
    ExampleData(33, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.three),
    ExampleData(34, "John Doe", DateTime(1977, 6, 17), true, ExampleEnum.one),
    ExampleData(35, "Jane Doe", DateTime(1977, 6, 17), true, ExampleEnum.two),
  ]);

  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ResponsiveDataGrid<ExampleData>.clientSide(
        title: TitleDefinition(
          title: "Testing Title",
          icon: Icon(Icons.help),
        ),
        items: widget.exampleData,
        itemTapped: (row) => print(row.name),
        pageSize: 20,
        pagingMode: PagingMode.pager,
        allowAggregations: true,
        allowGrouping: true,
        groupCriteria: [
          GroupCriteria(
            fieldName: "name",
            direction: OrderDirections.ascending,
            aggregates: [
              AggregateCriteria(
                fieldName: "name",
                aggregation: Aggregations.count,
              ),
            ],
          ),
        ],
        columns: [
          WidgetColumn(
            widget: (item) => Icon(Icons.check, color: Colors.green),
            xsCols: 1,
            fieldName: "Selected",
          ),
          IntColumn(
            xsCols: 2,
            fieldName: "id",
            header: ColumnHeader(
              text: "Id",
              showFilter: true,
              showOrderBy: true,
              showAggregations: true,
            ),
            value: (row) => row.id,
          ),
          StringColumn(
            xsCols: 5,
            mediumCols: 2,
            fieldName: "name",
            sortDirection: OrderDirections.ascending,
            filterRules: StringFilterRules(
              hintText: "Name",
            ),
            header: ColumnHeader(
              text: "Name",
              showFilter: true,
              showOrderBy: true,
            ),
            value: (row) => row.name,
            aggregations: [
              AggregateCriteria(
                fieldName: "name",
                aggregation: Aggregations.count,
              ),
            ],
          ),
          DateTimeColumn(
            xsCols: 4,
            mediumCols: 3,
            fieldName: "dob",
            filterRules: DateTimeFilterRules(
              filterType: DateTimeFilterTypes.DateOnly,
            ),
            header: ColumnHeader(
              text: "Date of Birth",
              showFilter: true,
              showOrderBy: true,
            ),
            value: (row) => row.dob,
            format: DateFormat.yMd(),
          ),
          BoolColumn(
            xsCols: 3,
            mediumCols: 2,
            fieldName: "accepted",
            header: ColumnHeader(
              text: "Accepted",
              showFilter: true,
              showOrderBy: true,
              showAggregations: true,
            ),
            value: (row) => row.accepted,
            trueText: "Yes",
            falseText: "No",
          ),
          EnumColumn<ExampleData, ExampleEnum>(
            values: ExampleEnum.values,
            fieldName: "exampleEnum",
            valueText: (value) => value == ExampleEnum.one
                ? "one"
                : value == ExampleEnum.two
                    ? "two"
                    : "three",
            value: (row) => row.exampleEnum,
            header: ColumnHeader(
              showFilter: true,
              showOrderBy: true,
              text: "Enum",
            ),
            xsCols: 4,
            mediumCols: 2,
          )
        ],
      ),
    );
  }
}

class ExampleData {
  final int id;
  final String name;
  final DateTime dob;
  final bool accepted;
  final ExampleEnum exampleEnum;

  const ExampleData(
    this.id,
    this.name,
    this.dob,
    this.accepted,
    this.exampleEnum,
  );
}

enum ExampleEnum {
  one,
  two,
  three,
}
