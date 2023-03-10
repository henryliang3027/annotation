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
  bool _onScaleUpdate = false;
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
  double _scaleFocalPointX = -1.0;
  double _shift = 0.0;
  double _xStep = 0.0;
  double _yStep = 0.0;
  DateTime _closestDateTime = DateTime.now();

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
    final double width = MediaQuery.of(context).size.width;
    const double height = 200;
    _yStep = height / _yRange;
    _xStep = (width - _rightOffset) / _xRange;

    DateTime _findClosetPoint() {
      double closestDistance = double.infinity;
      DateTime closestDateTime = DateTime.now();
      for (LineSeries lineSeries in widget.lineSeriesCollection) {
        for (DateTime dateTime in lineSeries.dataMap.keys) {
          double distance =
              (dateTime.difference(_minDate).inSeconds.toDouble() *
                          _xStep *
                          _scale -
                      _x +
                      _offset)
                  .abs();

          if (distance < closestDistance) {
            closestDistance = distance;
            closestDateTime = dateTime;
          }
        }
      }

      return closestDateTime;
    }

    return GestureDetector(
      onScaleStart: (details) {
        if (details.pointerCount == 2) {
          setState(() {
            _onScaleStart = true;
            _x = details.focalPoint.dx - _leftOffset;
            _closestDateTime = _findClosetPoint();
          });
        }
      },
      onScaleUpdate: (details) {
        setState(() {
          _onScaleUpdate = true;
          if (details.pointerCount == 2) {
            _scale = _baseScale * details.scale >= 1.0
                ? _baseScale * details.scale
                : 1.0;

            double scaledDistance =
                (_closestDateTime.difference(_minDate).inSeconds.toDouble() *
                            _xStep *
                            _scale -
                        _x +
                        _offset)
                    .abs();
            double originalDistance =
                (_closestDateTime.difference(_minDate).inSeconds.toDouble() *
                            _xStep *
                            _baseScale -
                        _x +
                        _offset)
                    .abs();

            _offset += -(_scale - _baseScale);

            print('2:${_offset} , ${scaledDistance}');
          }
          if (details.pointerCount == 1) {
            _shift += details.focalPointDelta.dx;
            _offset += details.focalPointDelta.dx;

            // print('1:${_offset}, $_scale');
            print('1:${_offset}, ${details.focalPointDelta.dx}');
          }
          //_closestDateTime = _findClosetPoint();
        });
      },
      onScaleEnd: (details) {
        _onScaleStart = false;
        _onScaleUpdate = false;
        _baseScale = _scale;
      },
      onLongPressMoveUpdate: (details) {
        setState(() {
          _x = details.localPosition.dx - _leftOffset;
          _closestDateTime = _findClosetPoint();
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
          _closestDateTime = _findClosetPoint();
        });
      },
      child: CustomPaint(
        size: Size(
          width,
          height,
        ),
        painter: LineChartPainter(
          lineSeriesCollection: widget.lineSeriesCollection,
          longestLineSeries: _longestLineSeries,
          showTooltip: _showTooltip,
          closestDateTime: _closestDateTime,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
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
