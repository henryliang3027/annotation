// import 'package:annotation/data_1.dart';
// import 'package:annotation/data_2.dart';
// import 'package:annotation/date_value_pair.dart';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late List<DateValuePair> _data1;
//   late List<DateValuePair> _data2;
//   late TrackballBehavior _trackballBehavior;
//   late ZoomPanBehavior _zoomPanBehavior;

//   List<DateValuePair> _getData(List jsonData) {
//     List<DateValuePair> dateValuePairs = [];
//     for (var item in jsonData) {
//       DateTime dateTime = DateTime.parse(item['time']);
//       double value = double.parse(item['value']);

//       dateValuePairs.add(DateValuePair(
//         dateTime: dateTime,
//         value: value,
//       ));
//     }

//     return dateValuePairs;
//   }

//   @override
//   void initState() {
//     _data1 = _getData(jsonData1);
//     _data2 = _getData(jsonData2);

//     _zoomPanBehavior = ZoomPanBehavior(
//         enablePanning: true,
//         enablePinching: true,
//         zoomMode: ZoomMode.x,
//         enableMouseWheelZooming: true);

//     _trackballBehavior = TrackballBehavior(
//       enable: true,
//       activationMode: ActivationMode.longPress,
//       tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
//     );

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.title,
//         ),
//       ),
//       body: Center(
//         child: SfCartesianChart(
//           primaryXAxis:
//               DateTimeAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
//           primaryYAxis: NumericAxis(),
//           trackballBehavior: _trackballBehavior,
//           zoomPanBehavior: _zoomPanBehavior,
//           series: <ChartSeries>[
//             LineSeries<DateValuePair, DateTime>(
//               dataSource: _data1,
//               xValueMapper: (DateValuePair dateValuePair, _) =>
//                   dateValuePair.dateTime,
//               yValueMapper: (DateValuePair dateValuePair, _) =>
//                   dateValuePair.value,
//             ),
//             // LineSeries<DateValuePair, DateTime>(
//             //   dataSource: _data2,
//             //   xValueMapper: (DateValuePair dateValuePair, _) =>
//             //       dateValuePair.dateTime,
//             //   yValueMapper: (DateValuePair dateValuePair, _) =>
//             //       dateValuePair.value,
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
