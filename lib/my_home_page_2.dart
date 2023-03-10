import 'package:annotation/data_1.dart';
import 'package:annotation/data_1_1.dart';
import 'package:annotation/data_2.dart';
import 'package:annotation/data_3.dart';
import 'package:annotation/data_3_3.dart';
import 'package:annotation/data_3_3_3.dart';
import 'package:annotation/data_3_3_3_3.dart';
import 'package:annotation/date_value_pair.dart';
import 'package:annotation/line_chart.dart';
import 'package:flutter/material.dart';

class MyHomePage2 extends StatefulWidget {
  const MyHomePage2({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage2> createState() => _MyHomePage2State();
}

class _MyHomePage2State extends State<MyHomePage2> {
  List<LineSeries> _lineSeriesCollection = [];
  LineSeries _getChartData1() {
    List<DateValuePair> dataList = [];
    Map<DateTime, double> dataMap = {};
    for (var data in jsonData3) {
      DateTime dateTime = DateTime.parse(data['time'].toString());
      double value = double.parse(data['value'].toString());
      dataList.add(DateValuePair(dateTime: dateTime, value: value));
      dataMap[dateTime] = value;
    }

    LineSeries lineSeries = LineSeries(
      name: 'Line1',
      dataList: dataList,
      dataMap: dataMap,
      color: Colors.red,
    );

    return lineSeries;
  }

  LineSeries _getChartData2() {
    List<DateValuePair> dataList = [];
    Map<DateTime, double> dataMap = {};
    for (var data in jsonData3_3) {
      DateTime dateTime = DateTime.parse(data['time'].toString());
      double value = double.parse(data['value'].toString());
      dataList.add(DateValuePair(dateTime: dateTime, value: value));
      dataMap[dateTime] = value;
    }

    LineSeries lineSeries = LineSeries(
      name: 'Line2',
      dataList: dataList,
      dataMap: dataMap,
      color: Colors.orange,
    );

    return lineSeries;
  }

  LineSeries _getChartData3() {
    List<DateValuePair> dataList = [];
    Map<DateTime, double> dataMap = {};
    for (var data in jsonData3_3_3) {
      DateTime dateTime = DateTime.parse(data['time'].toString());
      double value = double.parse(data['value'].toString());
      dataList.add(DateValuePair(dateTime: dateTime, value: value));
      dataMap[dateTime] = value;
    }

    LineSeries lineSeries = LineSeries(
      name: 'Line3',
      dataList: dataList,
      dataMap: dataMap,
      color: Colors.green,
    );

    return lineSeries;
  }

  LineSeries _getChartData4() {
    List<DateValuePair> dataList = [];
    Map<DateTime, double> dataMap = {};
    for (var data in jsonData3_3_3_3) {
      DateTime dateTime = DateTime.parse(data['time'].toString());
      double value = double.parse(data['value'].toString());
      dataList.add(DateValuePair(dateTime: dateTime, value: value));
      dataMap[dateTime] = value;
    }

    LineSeries lineSeries = LineSeries(
      name: 'Line4',
      dataList: dataList,
      dataMap: dataMap,
      color: Colors.blue,
    );

    return lineSeries;
  }

  int _getPointsCount() {
    int count = 0;
    for (LineSeries lineSeries in _lineSeriesCollection) {
      count += lineSeries.dataMap.length;
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    _lineSeriesCollection = [
      _getChartData1(),
      _getChartData2(),
      _getChartData3(),
      _getChartData4(),
    ];
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
            Center(
                child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'The number of points is: ',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: _getPointsCount().toString(),
                    style: const TextStyle(color: Colors.red, fontSize: 20),
                  ),
                ],
              ),
            )),
            RepaintBoundary(
              child: Container(
                width: 400,
                height: 200,
                child: LineChart(
                  lineSeriesCollection: _lineSeriesCollection,
                ),
              ),
            ),
            const SizedBox(
              height: 50.0,
            ),
            RepaintBoundary(
              child: Container(
                width: 400,
                height: 200,
                child: LineChart(
                  lineSeriesCollection: _lineSeriesCollection,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
