import 'dart:ui' as ui;
import 'package:annotation/date_value_pair.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScaleLineChartPainter extends CustomPainter {
  final List<DateValuePair> data;
  final double minValue;
  final double maxValue;
  final double minX;
  final double maxX;
  final double scale;
  final double xOffset;
  final double chartWidth;
  final double chartHeight;

  ScaleLineChartPainter({
    required this.data,
    required this.minValue,
    required this.maxValue,
    required this.minX,
    required this.maxX,
    required this.scale,
    required this.xOffset,
    required this.chartWidth,
    required this.chartHeight,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final axisPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

// Draw the x and y axes
    final yAxisStart = Offset(0, chartHeight);
    final yAxisEnd = Offset(0, 0);
    final xAxisStart = Offset(0, chartHeight);
    final xAxisEnd = Offset(chartWidth, chartHeight);

    canvas.drawLine(yAxisStart, yAxisEnd, axisPaint);
    canvas.drawLine(xAxisStart, xAxisEnd, axisPaint);

// Draw the y-axis tick marks and labels
    final yTickDistance = chartHeight / 5;
    final yValueRange = maxValue - minValue;
    final yValueIncrement = yValueRange / 5;

    for (int i = 0; i <= 5; i++) {
      final y = chartHeight - i * yTickDistance;
      final value = minValue + i * yValueIncrement;
      final textSpan = TextSpan(text: value.toStringAsFixed(2));
      final textPainter =
          TextPainter(text: textSpan, textDirection: ui.TextDirection.ltr);
      textPainter.layout();

      canvas.drawLine(Offset(-5, y), Offset(5, y), axisPaint);
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), axisPaint);
    }

// Draw the x-axis tick marks and labels
    final xTickDistance = chartWidth / 5;
    final xValueRange = maxX - minX;
    final xValueIncrement = xValueRange / 5;

    for (int i = 0; i <= 5; i++) {
      final x = i * xTickDistance;
      final value = minX + i * xValueIncrement;
      final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
      final textSpan = TextSpan(text: '${dateTime.month}/${dateTime.day}');
      final textPainter =
          TextPainter(text: textSpan, textDirection: ui.TextDirection.ltr);
      textPainter.layout();

      canvas.drawLine(
          Offset(x, chartHeight - 5), Offset(x, chartHeight + 5), axisPaint);
      canvas.drawLine(Offset(x, 0), Offset(x, chartHeight), axisPaint);
    }

// Draw the line chart
    final path = Path();
    final valueRange = maxValue - minValue;
    final valueScale = chartHeight / valueRange;
    final xAxisValueScale = 400.0 / (maxX - minX);

    for (int i = 0; i < data.length; i++) {
      final value = data[i].value;
      final x = (data[i].dateTime.millisecondsSinceEpoch.toDouble() - minX) *
              xAxisValueScale *
              scale +
          xOffset;
      final y = chartHeight - (value - minValue) * valueScale;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(ScaleLineChartPainter oldDelegate) {
    return true;
  }
}
