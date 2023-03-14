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
  //ds

  bool _showTooltip = false;
  bool _onScaleStart = false;
  double _x = 0.0;
  double _leftOffset = 40;
  double _rightOffset = 50;

  double _offset = 0.0;
  double _scale = 1.0;
  double _lastScaleValue = 1.0;

  double _minValue = 0.0;
  double _maxValue = 0.0;
  DateTime _minDate = DateTime.now();
  DateTime _maxDate = DateTime.now();
  double _xRange = 0.0;
  double _yRange = 0.0;
  late final LineSeries _longestLineSeries;
  double _focalPointX = 0.0;
  double _lastUpdateFocalPointX = 0.0;
  double _deltaFocalPointX = 0.0;

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
    double calculateOffsetX(
      double newScale,
      double focusOnScreen,
    ) {
      double widgetWidth = context.size!.width;

      double ratioInGraph =
          (_offset.abs() + focusOnScreen) / (_scale * widgetWidth);

      double newTotalWidth = newScale * widgetWidth;

      double newLocationInGraph = ratioInGraph * newTotalWidth;

      return focusOnScreen - newLocationInGraph;
    }

    updateScaleAndScrolling(double newScale, double focusX,
        {double extraX = 0.0}) {
      var widgetWidth = context.size!.width;

      newScale = newScale.clamp(1.0, 30.0);

      // 根据缩放焦点计算出left
      double left = calculateOffsetX(newScale, focusX);

      // 加上额外的水平偏移量
      left += extraX;
      print('1: ${left}');
      // 将x范围限制图表宽度内
      double newOffsetX = left.clamp((newScale - 1) * -widgetWidth, 0.0);

      setState(() {
        _scale = newScale;
        _offset = newOffsetX;
      });
    }

    return GestureDetector(
      onScaleStart: (details) {
        _focalPointX = details.focalPoint.dx;
        _lastScaleValue = _scale;
        _lastUpdateFocalPointX = details.focalPoint.dx;
        _onScaleStart = true;
      },
      onScaleUpdate: (details) {
        _onScaleStart = false;

        double newScale = (_lastScaleValue * details.scale);

        _deltaFocalPointX = (details.focalPoint.dx - _lastUpdateFocalPointX);
        _lastUpdateFocalPointX = details.focalPoint.dx;

        updateScaleAndScrolling(newScale, _focalPointX,
            extraX: _deltaFocalPointX);
      },
      onScaleEnd: (details) {
        _onScaleStart = false;
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
