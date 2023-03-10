import 'dart:ui' as ui;
import 'package:annotation/date_value_pair.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartPainter extends CustomPainter {
  final List<LineSeries> lineSeriesCollection;
  final LineSeries longestLineSeries;
  final bool showTooltip;
  final DateTime closestDateTime;
  final bool onScaleStart;
  final bool onScaleUpdate;
  final double x;
  final double leftOffset;
  final double rightOffset;
  final double offset;
  final double scale;
  final double minValue;
  final double maxValue;
  final DateTime minDate;
  final DateTime maxDate;
  final double xRange;
  final double yRange;

  LineChartPainter({
    required this.lineSeriesCollection,
    required this.longestLineSeries,
    required this.showTooltip,
    required this.closestDateTime,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.x,
    required this.leftOffset,
    required this.rightOffset,
    required this.offset,
    required this.scale,
    required this.minValue,
    required this.maxValue,
    required this.minDate,
    required this.maxDate,
    required this.xRange,
    required this.yRange,
  });

  // find closet from longest line series and get datetime from another lineseries
  // if there is no value from another lineseries than return null
  DateTime _findClosetPoint({
    required double tapX,
    required double xStep,
  }) {
    double closestDistance = double.infinity;
    DateTime closestDateTime = DateTime.now();
    for (LineSeries lineSeries in lineSeriesCollection) {
      for (DateTime dateTime in lineSeries.dataMap.keys) {
        double distance =
            (dateTime.difference(minDate).inSeconds.toDouble() * xStep -
                    x +
                    offset)
                .abs();

        if (distance < closestDistance) {
          closestDistance = distance;
          closestDateTime = dateTime;
        }
      }
    }

    return closestDateTime;
  }

  List<Map<String, double?>> _getValueByDateTime(DateTime dateTime) {
    List<Map<String, double?>> valueMapList = [];
    for (LineSeries lineSeries in lineSeriesCollection) {
      Map<String, double?> valueMap = {};
      valueMap[lineSeries.name] = lineSeries.dataMap[dateTime];
      valueMapList.add(valueMap);
    }
    // valueMapList = [{'name': value},{'name': value}]
    return valueMapList;
  }

  @override
  void paint(Canvas canvas, Size size) {
    TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    double yStep = size.height / yRange;

    // Draw Y-axis scale points and horizontal grid line
    int yScalePoints = 5;
    double yInterval = yRange / yScalePoints;
    for (int i = 0; i < yScalePoints; i++) {
      double scaleY = size.height - i * yInterval * yStep;
      canvas.drawLine(Offset(leftOffset, scaleY),
          Offset(size.width - rightOffset + leftOffset, scaleY), gridPaint);
      String label = (i * yInterval + minValue).toStringAsFixed(1);
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(10, scaleY));
    }
    //canvas.clipRect(const Rect.fromLTRB(10, 0, 100, 200));
    canvas.translate(leftOffset, 0);

    double xStep = (size.width - rightOffset) / xRange;

    for (LineSeries lineSeries in lineSeriesCollection) {
      List<DateValuePair> data = lineSeries.dataList;
      Path linePath = Path();

      Paint linePaint = Paint()
        ..color = lineSeries.color
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < data.length; i++) {
        double scaleX =
            (data[i].dateTime.difference(minDate).inSeconds * xStep) * scale +
                offset;
        double scaleY = (maxValue - data[i].value) * yStep;
        if (i == 0) {
          linePath.moveTo(scaleX, scaleY);
        } else {
          linePath.lineTo(scaleX, scaleY);
        }
      }

      canvas.drawPath(linePath, linePaint);
    }

    if (showTooltip) {
      // draw vertical line at the closest point
      Paint verticalLinePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(
            (closestDateTime.difference(minDate).inSeconds.toDouble() *
                    xStep *
                    scale +
                offset),
            0),
        Offset(
            (closestDateTime.difference(minDate).inSeconds.toDouble() *
                    xStep *
                    scale +
                offset),
            size.height),
        verticalLinePaint,
      );

      String formatDateTime = _formatDate(closestDateTime);

      TextSpan span = TextSpan(
        text: formatDateTime,
        style: const TextStyle(
          color: Colors.black,
        ),
      );
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: ui.TextDirection.ltr);
      tp.layout();
      double textX = (closestDateTime.difference(minDate).inSeconds.toDouble() *
                  xStep *
                  scale +
              offset) -
          (tp.width / 2);
      double textY = size.height - tp.height;
      tp.paint(canvas, Offset(textX, textY));

      List<Map<String, double?>> valueMapList =
          _getValueByDateTime(closestDateTime);
      for (int j = 0; j < valueMapList.length; j++) {
        Map<String, double?> nameValue = valueMapList[j];
        MapEntry nameValueEntry = nameValue.entries.toList()[0];
        if (nameValueEntry.value != null) {
          String formatNameValue =
              '${nameValueEntry.key} : ${nameValueEntry.value}';

          TextSpan nameValueSpan = TextSpan(
            text: formatNameValue,
            style: const TextStyle(
              color: Colors.black,
            ),
          );
          TextPainter nameValueTp = TextPainter(
              text: nameValueSpan,
              textAlign: TextAlign.center,
              textDirection: ui.TextDirection.ltr);
          nameValueTp.layout();

          double nameValueTpTextY = size.height - tp.height + 14 * (j + 1);
          nameValueTp.paint(canvas, Offset(textX + 14, nameValueTpTextY));

          Paint circlePaint = Paint()..color = lineSeriesCollection[j].color;
          Offset center = Offset(textX + 4, nameValueTpTextY + 8);
          double radius = 4;
          canvas.drawCircle(center, radius, circlePaint);
        }
      }
    }

    Paint axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    // Draw X-axis line
    canvas.drawLine(Offset(0, size.height),
        Offset(size.width - rightOffset, size.height), axisPaint);

    // Draw Y-axis line
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint);

    // Draw X-axis scale points and vertical grid line
    int xScalePoints = 5;
    double xInterval = longestLineSeries.dataList.length / xScalePoints;
    for (int i = 0; i < xScalePoints; i++) {
      double scaleX = (longestLineSeries
              .dataList[(i * xInterval).round()].dateTime
              .difference(minDate)
              .inSeconds
              .toDouble() *
          xStep);
      canvas.drawLine(Offset(scaleX * scale + offset, 0),
          Offset(scaleX * scale + offset, size.height), gridPaint);

      String label = DateFormat('MM/dd')
          .format(longestLineSeries.dataList[(i * xInterval).floor()].dateTime);

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(scaleX * scale + offset, size.height));
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.showTooltip != showTooltip ||
        oldDelegate.x != x ||
        oldDelegate.scale != scale ||
        oldDelegate.offset != offset;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date).toString();
    ;
  }
}
