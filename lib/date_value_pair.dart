import 'package:flutter/material.dart';

class DateValuePair {
  const DateValuePair({
    required this.dateTime,
    required this.value,
  });

  final DateTime dateTime;
  final double value;
}

class LineSeries {
  const LineSeries({
    required this.name,
    required this.dataList,
    required this.dataMap,
    required this.color,
  });

  final String name;
  final List<DateValuePair> dataList;
  final Map<DateTime, double> dataMap;
  final Color color;
}
