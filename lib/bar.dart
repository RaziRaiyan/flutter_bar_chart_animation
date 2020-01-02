import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'color_palette.dart';

class Bar{

  Bar(this.height,this.color);

  factory Bar.empty() => Bar(0.0,Colors.transparent);

  factory Bar.random(Random random){
    return Bar(
        random.nextDouble()*300.0,
        ColorPalette.primary.random(random)
    );
  }

  final double height;
  final Color color;


  static Bar lerp(Bar begin,Bar end,double t){
    return Bar(
        lerpDouble(begin.height, end.height, t),
        Color.lerp(begin.color, end.color, t));
  }
}

class BarTween extends Tween<Bar>{

  BarTween(Bar begin, Bar end): super(begin: begin,end: end);

  @override
  Bar lerp(double t) => Bar.lerp(begin, end, t);
}

class BarChart{

  static const int barCount = 15;

  BarChart(this.bars){
    assert(bars.length == barCount);
  }

  factory BarChart.empty(){
    return BarChart(List.filled(barCount, Bar(0.0,Colors.transparent)));
  }

  factory BarChart.random(Random random) {
    final Color color = ColorPalette.primary.random(random);
    return BarChart(List.generate(
      barCount,
          (i) => Bar(random.nextDouble() * 300.0, color),
    ));
  }

  final List<Bar> bars;

  static BarChart lerp(BarChart begin,BarChart end,double t){
    return BarChart(List.generate(
        barCount,
            (i) => Bar.lerp(begin.bars[i], end.bars[i], t)));
  }

}

class BarChartTween extends Tween<BarChart>{
  BarChartTween(BarChart begin,BarChart end):super(begin:begin,end: end);

  @override
  BarChart lerp(double t) => BarChart.lerp(begin, end, t);
}

class BarChartPainter extends CustomPainter {
  static const barWidthFraction = 0.75;

  BarChartPainter(Animation<BarChart> animation)
      : animation = animation,
        super(repaint: animation);

  final Animation<BarChart> animation;

  @override
  void paint(Canvas canvas, Size size) {
    void drawBar(Bar bar, double x, double width, Paint paint) {
      paint.color = bar.color;
      Rect rect = Rect.fromLTWH(x, size.height - bar.height, width, bar.height);
      RRect roundedRect = RRect.fromRectAndCorners(rect,topLeft: Radius.circular(10),topRight: Radius.circular(10) );

      canvas.drawRRect(
        roundedRect,
        paint,
      );
    }

    final paint = Paint()
      ..style = PaintingStyle.fill;
    final chart = animation.value;
    final barDistance = size.width / (1 + chart.bars.length);
    final barWidth = barDistance * barWidthFraction;
    var x = barDistance - barWidth / 2;
    for (final bar in chart.bars) {
      drawBar(bar, x, barWidth, paint);
      x += barDistance;
    }
  }

  double degToRadian({double degree}){
    return (degree/180)*3.14;
  }

  @override
  bool shouldRepaint(BarChartPainter old) => false;
}
