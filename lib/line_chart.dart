import 'package:annotation/chart_painter.dart';
import 'package:annotation/date_value_pair.dart';
import 'package:flutter/material.dart';

class LineChart extends StatefulWidget {
  final List<LineSeries> lineSeriesCollection;

  const LineChart({super.key, required this.lineSeriesCollection});

  @override
  LineChartState createState() => LineChartState();
}

class LineChartState extends State<LineChart> {
  bool _showTooltip = false;
  bool _onScaleStart = false;
  double _x = 0.0;
  double _leftOffset = 40;
  double _rightOffset = 50;

  double _offset = 0.0;
  double _scale = 1.0;
  double _baseScale = 1.0;

  double _minValue = 0.0;
  double _maxValue = 0.0;
  DateTime _minDate = DateTime.now();
  DateTime _maxDate = DateTime.now();
  double _xRange = 0.0;
  double _yRange = 0.0;
  late final LineSeries _longestLineSeries;

  @override
  void initState() {
    super.initState();
    List<LineSeries> lineSeriesCollection = widget.lineSeriesCollection;

    List<double> allValues = lineSeriesCollection
        .expand((lineSeries) => lineSeries.dataMap.values)
        .toList();

    List<DateTime> allDateTimes = lineSeriesCollection
        .expand((lineSeries) => lineSeries.dataMap.keys)
        .toList();

    _minValue = allValues
            .map((value) => value)
            .reduce((value, element) => value < element ? value : element) -
        10;
    _maxValue = allValues
            .map((value) => value)
            .reduce((value, element) => value > element ? value : element) +
        10;

    _minDate = allDateTimes
        .map((dateTime) => dateTime)
        .reduce((value, element) => value.isBefore(element) ? value : element);
    _maxDate = allDateTimes
        .map((dateTime) => dateTime)
        .reduce((value, element) => value.isAfter(element) ? value : element);

    _xRange = _maxDate.difference(_minDate).inSeconds.toDouble();
    _yRange = _maxValue - _minValue;

    _longestLineSeries = lineSeriesCollection
        .map((lineSeries) => lineSeries)
        .reduce((value, element) =>
            value.dataMap.length > element.dataMap.length ? value : element);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        // setState(() {});

        if (details.pointerCount == 2) {
          print('onScaleStart');

          _onScaleStart = true;
        }
      },
      onScaleUpdate: (details) {
        setState(() {
          _onScaleStart = false;
          if (details.pointerCount == 2) {
            _scale = _baseScale * details.scale >= 1.0
                ? _baseScale * details.scale
                : 1.0;

            // get the local position of the tap
            final newOffset = details.focalPoint.dx * _scale;

            //_offset = -newOffset + details.focalPoint.dx * _baseScale;
            _offset = -(details.focalPoint.dx * _scale - details.focalPoint.dx);
            print('0:${_offset}');
            print('0:${-newOffset}, ${details.focalPoint.dx * _baseScale}');
          }
          if (details.pointerCount == 1) {
            _offset += details.focalPointDelta.dx;
            // print('1:${_offset}');
          }
        });
      },
      onScaleEnd: (details) {
        _onScaleStart = false;
        _baseScale = _scale;
      },
      onLongPressMoveUpdate: (details) {
        setState(() {
          _x = details.localPosition.dx - _leftOffset;
        });
      },
      onLongPressEnd: (details) {
        setState(() {
          _showTooltip = false;
        });
      },
      onLongPressStart: (details) {
        setState(() {
          _showTooltip = true;
          _x = details.localPosition.dx - _leftOffset;
        });
      },
      child: CustomPaint(
        painter: LineChartPainter(
          lineSeriesCollection: widget.lineSeriesCollection,
          longestLineSeries: _longestLineSeries,
          showTooltip: _showTooltip,
          onScaleStart: _onScaleStart,
          x: _x,
          leftOffset: _leftOffset,
          rightOffset: _rightOffset,
          offset: _offset,
          scale: _scale,
          minValue: _minValue,
          maxValue: _maxValue,
          minDate: _minDate,
          maxDate: _maxDate,
          xRange: _xRange,
          yRange: _yRange,
        ),
      ),
    );
  }
}
