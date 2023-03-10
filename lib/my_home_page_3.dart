import 'package:annotation/data_1.dart';
import 'package:annotation/data_2.dart';
import 'package:annotation/data_3.dart';
import 'package:annotation/date_value_pair.dart';
import 'package:annotation/line_chart.dart';
import 'package:annotation/scale_line_chart.dart';
import 'package:flutter/material.dart';

class MyHomePage3 extends StatefulWidget {
  const MyHomePage3({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage3> createState() => _MyHomePage3State();
}

class _MyHomePage3State extends State<MyHomePage3> {
  List<DateValuePair> _getChartData() {
    List<DateValuePair> chartData = [];
    for (var data in jsonData3) {
      DateTime dateTime = DateTime.parse(data['time'].toString());
      double value = double.parse(data['value'].toString());
      chartData.add(DateValuePair(dateTime: dateTime, value: value));
    }
    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 400,
              height: 200,
              child: ScaleLineChart(
                data: _getChartData(),
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
            Container(
              width: 400,
              height: 200,
              child: ScaleLineChart(
                data: _getChartData(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
