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
        dataTableTheme: Theme.of(context).dataTableTheme.copyWith(
            headingRowColor: MaterialStateProperty.all(Colors.black54)),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final exampleData = List<ExampleData>.from([
    ExampleData(1, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(2, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(3, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(4, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(5, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(6, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(7, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(8, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(9, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(10, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(11, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(12, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(13, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(14, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(15, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(16, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(17, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(18, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(19, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(20, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(21, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(22, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(23, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(24, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(25, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(26, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(27, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(28, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(29, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(30, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(31, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(32, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(33, "Jane Doe", DateTime(1977, 6, 17), true),
    ExampleData(34, "John Doe", DateTime(1977, 6, 17), true),
    ExampleData(35, "Jane Doe", DateTime(1977, 6, 17), true),
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
      body: ResponsiveDataGrid<ExampleData>(
        title: TitleDefinition(
          title: "Testing Title",
          icon: Icon(Icons.help),
        ),
        itemTapped: (row) => print(row.name),
        columns: [
          ColumnDefinition(
            xsCols: 2,
            fieldName: "id",
            header: ColumnHeaderDefinition(
              text: "Id",
              orderRules: OrderRules(showSort: true),
              filterRules: IntFilterRules(
                filterable: true,
              ),
            ),
            value: (row) => row.id,
          ),
          ColumnDefinition(
            xsCols: 6,
            mediumCols: 4,
            fieldName: "name",
            header: ColumnHeaderDefinition(
              text: "Name",
              showMenu: true,
              orderRules: OrderRules(showSort: true),
              filterRules: ValueMapFilterRules(
                valueMap: {"John": Text("John"), "Doe": Text("Doe")},
                filterable: true,
              ),
            ),
            value: (row) => row.name,
          ),
          ColumnDefinition(
            xsCols: 4,
            mediumCols: 3,
            fieldName: "dob",
            header: ColumnHeaderDefinition(
              text: "Date of Birth",
              showMenu: true,
              orderRules: OrderRules(showSort: true),
              filterRules: DateTimeFilterRules(
                filterType: DateTimeFilterTypes.DateOnly,
                filterable: true,
              ),
            ),
            value: (row) => DateFormat.yMd().format(row.dob),
          ),
          ColumnDefinition(
            xsCols: 4,
            mediumCols: 2,
            fieldName: "accepted",
            header: ColumnHeaderDefinition(
              text: "Accepted",
              showMenu: true,
              orderRules: OrderRules(showSort: true),
              filterRules: BoolFilterRules(
                filterable: true,
              ),
            ),
            value: (row) => row.accepted ? "Yes" : "No",
          )
        ],
        loadData: load,
      ),
    );
  }

  Future<LoadResult<ExampleData>> load(LoadCriteria criteria) {
    return Future.value(
      LoadResult(
        totalCount: widget.exampleData.length,
        items: widget.exampleData,
      ),
    );
  }
}

class ExampleData {
  final int id;
  final String name;
  final DateTime dob;
  final bool accepted;

  const ExampleData(this.id, this.name, this.dob, this.accepted);
}
