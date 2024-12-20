import 'dart:math';

import 'package:flutter/material.dart';

import 'pp_spin_wheel_item.dart';

/// 绘制三角形
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 绘制转盘
class WheelPainter extends CustomPainter {
  final List<PPSpinWheelItem> items;
  final double totalWeight;
  final TextStyle textStyle;
  final bool enableWeight;
  final Function(List<double>)? onItemAnglesUpdated;

  // 记录每个item的角度范围,从12点钟方向开始
  final List<(double startAngle, double endAngle)> itemAngleRanges = [];
  // 记录每个item的中间角度,从12点钟方向开始
  final List<double> itemAngles = [];

  WheelPainter({
    required this.items,
    required this.totalWeight,
    required this.enableWeight,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
    this.onItemAnglesUpdated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    double startAngle = 0; // 默认从3点钟方向开始
    itemAngleRanges.clear();
    itemAngles.clear();

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final sweepAngle = enableWeight
          ? 2 * pi * (item.weight / totalWeight)
          : 2 * pi / items.length;

      final normalizedStartAngle = startAngle;
      final normalizedEndAngle = startAngle + sweepAngle;
      itemAngleRanges.add((normalizedStartAngle, normalizedEndAngle));
      itemAngles.add(normalizedStartAngle + sweepAngle / 2);

      // 绘制扇形
      final paint = Paint()
        ..color = item.bgColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // 如果被选中,绘制黑色半透明遮罩
      if (item.selected) {
        final overlayPaint = Paint()
          ..color = const Color.fromRGBO(0, 0, 0, 0.6)
          ..style = PaintingStyle.fill;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          overlayPaint,
        );
      }

      // 计算可用的扇形宽度
      final arcWidth = radius * sin(sweepAngle / 2) * 2;

      // 绘制文字
      var scaledTextStyle = textStyle;
      final textPainter = TextPainter(
        text: TextSpan(
          text: item.title,
          style: scaledTextStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // 如果文字宽度超过扇形可用宽度的80%,缩小字体
      if (textPainter.width > arcWidth * 0.8) {
        // 计算缩放因子,但限制最小缩放为0.8
        var scaleFactor = (arcWidth * 0.8) / textPainter.width;
        scaleFactor = scaleFactor < 0.8 ? 0.8 : scaleFactor;

        scaledTextStyle = textStyle.copyWith(
          fontSize: (textStyle.fontSize ?? 16) * scaleFactor,
        );

        textPainter.text = TextSpan(
          text: item.title,
          style: scaledTextStyle,
        );
        textPainter.layout();
      }

      // 计算文字位置 - 在扇形中心
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.6; // 文字距离圆心60%半径处
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      // 移动画布原点到文字位置并旋转
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi);
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();

      startAngle += sweepAngle;
    }
    // print(
    //     'itemAngleRanges in degrees: ${itemAngleRanges.map((range) => '${(range.$1 * 180 / pi).toStringAsFixed(2)}° - ${(range.$2 * 180 / pi).toStringAsFixed(2)}°')}');
    // 回调角度范围数据
    onItemAnglesUpdated?.call(itemAngles);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 自定义动画曲线
class SpinningCurve extends Curve {
  @override
  double transformInternal(double t) {
    //print('t: $t');
    // 前70%快速旋转
    if (t < 0.7) {
      // 使用easeIn曲线加速旋转
      return Curves.easeIn.transform(t / 0.7) * 2.0;
    }
    // 后30%慢慢停止
    return 2.0 + (Curves.decelerate.transform((t - 0.7) / 0.3) - 1.0) * 0.5;
  }
}

// 自定义物理效果曲线
class PhysicsSpinCurve extends Curve {
  @override
  double transformInternal(double t) {
    // 使用三段式曲线:
    // 1. 快速加速(0-0.3)
    // 2. 匀速旋转(0.3-0.7)
    // 3. 缓慢减速(0.7-1.0)
    if (t < 0.3) {
      // 加速阶段使用 easeIn
      return Curves.easeIn.transform(t / 0.3);
    } else if (t < 0.7) {
      // 匀速阶段
      return 1.0;
    } else {
      // 减速阶段使用 elasticOut 来模拟物理摩擦和弹性
      return 1.0 + (Curves.elasticOut.transform((t - 0.7) / 0.3) - 1.0);
    }
  }
}
