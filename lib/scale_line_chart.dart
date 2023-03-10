import 'package:annotation/chart_painter.dart';
import 'package:annotation/date_value_pair.dart';
import 'package:annotation/scale_line_chart_painter.dart';
import 'package:flutter/material.dart';

class ScaleLineChart extends StatefulWidget {
  final List<DateValuePair> data;

  const ScaleLineChart({super.key, required this.data});

  @override
  ScaleLineChartState createState() => ScaleLineChartState();
}

class ScaleLineChartState extends State<ScaleLineChart> {
  double _minValue = 0;
  double _maxValue = 0;
  double _minX = 0;
  double _maxX = 0;
  double _scale = 1.0;
  double _xOffset = 0.0;
  double _chartWidth = 0.0;
  double _chartHeight = 0.0;

  @override
  void initState() {
    super.initState();
    List<DateValuePair> data = widget.data;

    // Find the minimum and maximum values of the data
    _minValue = data
            .map((d) => d.value)
            .reduce((value, element) => value < element ? value : element) -
        10;
    _maxValue = data
            .map((d) => d.value)
            .reduce((value, element) => value > element ? value : element) +
        10;

    // Find the minimum and maximum x values of the data
    _minX = widget.data.first.dateTime.millisecondsSinceEpoch.toDouble();
    _maxX = widget.data.last.dateTime.millisecondsSinceEpoch.toDouble();

    // Calculate the initial scale and xOffset
    _scale = 1.0;
    _xOffset = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _chartWidth = constraints.maxWidth;
        _chartHeight = constraints.maxHeight;

        return GestureDetector(
          onScaleUpdate: (ScaleUpdateDetails details) {
            // Calculate the new scale and xOffset based on the focal point
            final newScale = _scale * details.scale;
            final newOffset = (_chartWidth / 2 - details.focalPoint.dx) *
                (_scale - newScale) /
                _scale;

            // Update the scale and xOffset
            setState(() {
              _scale = newScale;
              _xOffset += newOffset;
            });
          },
          child: CustomPaint(
            painter: ScaleLineChartPainter(
              data: widget.data,
              minValue: _minValue,
              maxValue: _maxValue,
              minX: _minX,
              maxX: _maxX,
              scale: _scale,
              xOffset: _xOffset,
              chartWidth: _chartWidth,
              chartHeight: _chartHeight,
            ),
          ),
        );
      },
    );
  }
}
