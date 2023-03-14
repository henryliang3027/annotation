import 'dart:ui' as ui;
import 'package:annotation/date_value_pair.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartPainter extends CustomPainter {
  final List<LineSeries> lineSeriesCollection;
  final LineSeries longestLineSeries;
  final bool showTooltip;
  final bool onScaleStart;
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
    required this.onScaleStart,
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
    required double offsetX,
    required double xStep,
  }) {
    double closestDistance = double.infinity;
    DateTime closestDateTime = DateTime.now();
    for (LineSeries lineSeries in lineSeriesCollection) {
      for (DateTime dateTime in lineSeries.dataMap.keys) {
        // because sthe start point of line series is in canvas.translate(leftOffset + offset, 0);
        // add offsetX to adjust the difference between target datetime and min datetime
        double distance =
            (dateTime.difference(minDate).inSeconds.toDouble() * xStep +
                    offsetX -
                    x)
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

    // Draw horizontal grid line and Y-axis scale points
    int yScalePoints = 5;
    double yInterval = yRange / yScalePoints;
    for (int i = 0; i < yScalePoints; i++) {
      double scaleY = size.height - i * yInterval * yStep;

      // Draw horizontal grid line
      canvas.drawLine(Offset(leftOffset, scaleY),
          Offset(size.width - rightOffset + leftOffset, scaleY), gridPaint);

      // Draw Y-axis scale points
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

    canvas.save();
    canvas.translate(leftOffset, 0);
    Paint axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    // Draw X-axis line
    canvas.drawLine(Offset(0, size.height),
        Offset(size.width - rightOffset, size.height), axisPaint);

    // Draw Y-axis line
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), axisPaint);
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromPoints(Offset(leftOffset, 0),
        Offset(size.width + leftOffset - rightOffset + 1, size.height + 20)));
    canvas.translate(leftOffset + offset, 0);

    double xStep = (size.width * scale - rightOffset) / xRange;

    // Draw vertical grid line and X-Axis scale points
    int xScalePoints = 5;
    double xInterval = longestLineSeries.dataList.length / xScalePoints;
    for (int i = 0; i < xScalePoints; i++) {
      double scaleX = (longestLineSeries
              .dataList[(i * xInterval).round()].dateTime
              .difference(minDate)
              .inSeconds
              .toDouble() *
          xStep);

      // Draw vertical grid line
      canvas.drawLine(
          Offset(scaleX, 0), Offset(scaleX, size.height), gridPaint);

      // Draw X-Axis scale points
      String label = DateFormat('MM/dd')
          .format(longestLineSeries.dataList[(i * xInterval).floor()].dateTime);

      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(scaleX, size.height));
    }

    // Draw line series
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
            (data[i].dateTime.difference(minDate).inSeconds * xStep);
        double scaleY = (maxValue - data[i].value) * yStep;
        if (i == 0) {
          linePath.moveTo(scaleX, scaleY);
        } else {
          linePath.lineTo(scaleX, scaleY);
        }
      }

      canvas.drawPath(linePath, linePaint);

      if (showTooltip) {
        DateTime closestDateTime = _findClosetPoint(
          tapX: x,
          offsetX: offset,
          xStep: xStep,
        );

        // draw vertical line at the closest point
        Paint verticalLinePaint = Paint()
          ..color = Colors.black
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(
              (closestDateTime.difference(minDate).inSeconds.toDouble() *
                  xStep),
              0),
          Offset(
              (closestDateTime.difference(minDate).inSeconds.toDouble() *
                  xStep),
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
        double textX =
            (closestDateTime.difference(minDate).inSeconds.toDouble() * xStep) -
                (tp.width / 2);
        double textY = size.height / 2 - tp.height;
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

            double nameValueTpTextY = textY + 14 * (j + 1);
            nameValueTp.paint(canvas, Offset(textX + 14, nameValueTpTextY));

            Paint circlePaint = Paint()..color = lineSeriesCollection[j].color;
            Offset center = Offset(textX + 4, nameValueTpTextY + 8);
            double radius = 4;
            canvas.drawCircle(center, radius, circlePaint);
          }
        }
      }
    }

    canvas.restore();
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
