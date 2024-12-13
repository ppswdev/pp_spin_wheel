import 'dart:math';
import 'package:flutter/material.dart';

import 'pp_spin_wheel_item.dart';
import 'pp_spin_wheel_painters.dart';

/// 旋转盘
class PPSpinWheel extends StatefulWidget {
  final List<PPSpinWheelItem> items;
  final double size;
  final double backgroundSize;
  final double wheelSize;
  final Widget? backgroundImage;
  final Widget? overlay;
  final Widget? spinIcon;
  final Widget? indicator;
  final bool enableWeight;
  final TextStyle? textStyle;
  final int numberOfTurns;
  final List<int>? filterIndexs;
  final Function(int)? onItemPressed;
  final VoidCallback? onStartPressed;
  final Function(int)? onAnimationEnd;
  final VoidCallback? onSpinFastAudio;
  final VoidCallback? onSpinSlowAudio;

  const PPSpinWheel({
    super.key,
    required this.items,
    this.size = 350,
    this.wheelSize = 320,
    this.backgroundSize = 350,
    this.backgroundImage,
    this.overlay,
    this.spinIcon,
    this.indicator,
    this.enableWeight = false,
    this.textStyle,
    this.numberOfTurns = 12,
    this.filterIndexs,
    this.onItemPressed,
    this.onStartPressed,
    this.onAnimationEnd,
    this.onSpinFastAudio,
    this.onSpinSlowAudio,
  });

  @override
  State<PPSpinWheel> createState() => _PPSpinWheelState();
}

class _PPSpinWheelState extends State<PPSpinWheel>
    with SingleTickerProviderStateMixin {
  List<double> _itemAngles = [];
  late AnimationController _animationController;
  Animation<double>? _spinAnimation;
  var _isSpinning = false;
  var _currentAngle = 0.0;
  var _currentItemIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animationController.addListener(() {
      // 可以在这里添加声音效果
      if (_animationController.value < 0.3) {
        // 快速旋转音效
        widget.onSpinFastAudio?.call();
      } else if (_animationController.value > 0.7) {
        // 减速音效
        widget.onSpinSlowAudio?.call();
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        widget.onAnimationEnd?.call(_currentItemIndex);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Start spin animation
  void _startSpinAnimation() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    // 保持当前角度,避免突然跳转
    List<int> availableIndexs = List.generate(widget.items.length, (i) => i);
    if (widget.filterIndexs != null) {
      availableIndexs.removeWhere((i) => widget.filterIndexs!.contains(i));
    }
    _currentItemIndex =
        availableIndexs[Random().nextInt(availableIndexs.length)];
    _currentAngle = 0.0;
    // 计算目标角度时考虑当前角度,基础旋转圈数 + 调整到目标位置所需的额外角度
    final targetAngle = widget.numberOfTurns * 2 * pi +
        (-pi / 2 - _itemAngles[_currentItemIndex]);

    // print('_itemAngles: $_itemAngles');
    // print(
    //     'currentAngle: $_currentAngle, itemAngle: ${_itemAngles[_currentItemIndex]}, targetAngle: $targetAngle, _currentItemIndex: $_currentItemIndex');

    _spinAnimation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _animationController,
      // 使用缓动曲线让结束更平滑
      curve: Curves.easeOutCubic,
    ));

    _animationController.reset();
    _animationController.forward();
  }

  /// Tap wheel position
  void _onTapWheel(Offset localPosition) {
    if (_isSpinning) return;

    final center = Size(widget.wheelSize, widget.wheelSize).center(Offset.zero);

    // 计算点击位置相对于圆心的角度
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final angle = atan2(dy, dx);

    // 将角度转换为0-2π范围
    final normalizedAngle = angle < 0 ? angle + 2 * pi : angle;

    // 计算总权重
    final totalWeight = widget.enableWeight
        ? widget.items.fold(0.0, (sum, item) => sum + item.weight)
        : widget.items.length.toDouble();

    // 找出点击的扇形区域
    double startAngle = 0;
    for (var i = 0; i < widget.items.length; i++) {
      final sweepAngle = widget.enableWeight
          ? 2 * pi * (widget.items[i].weight / totalWeight)
          : 2 * pi / widget.items.length;
      if (normalizedAngle >= startAngle &&
          normalizedAngle < startAngle + sweepAngle) {
        setState(() {
          final List<PPSpinWheelItem> newItems = List.of(widget.items);
          newItems[i] = widget.items[i].copyWith(
            selected: !widget.items[i].selected,
          );
          widget.items.clear();
          widget.items.addAll(newItems);
        });
        widget.onItemPressed?.call(i);
        break;
      }
      startAngle += sweepAngle;
    }
  }

  /// Start spin animation
  void startSpin() {
    widget.onStartPressed?.call();
    _isSpinning = false;
    _startSpinAnimation();
  }

  @override
  Widget build(BuildContext context) {
    // 计算总权重
    final totalWeight = widget.enableWeight
        ? widget.items.fold(0.0, (sum, item) => sum + item.weight)
        : widget.items.length.toDouble();
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(children: [
        // 背景
        Center(
          child: SizedBox(
            width: widget.backgroundSize,
            height: widget.backgroundSize,
            child:
                widget.backgroundImage ?? Container(color: Colors.transparent),
          ),
        ),
        // 轮盘
        Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              _currentAngle = _spinAnimation?.value ?? _currentAngle;
              return Transform.rotate(
                angle: _currentAngle,
                child: GestureDetector(
                  onTapDown: (details) => _onTapWheel(details.localPosition),
                  child: CustomPaint(
                    size: Size(widget.wheelSize, widget.wheelSize),
                    painter: WheelPainter(
                      items: widget.items,
                      totalWeight: totalWeight,
                      enableWeight: widget.enableWeight,
                      textStyle: widget.textStyle ??
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                      onItemAnglesUpdated: (angles) {
                        _itemAngles = angles;
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // 轮盘覆盖图层
        if (widget.overlay != null)
          Center(
            child: IgnorePointer(
              child: widget.overlay!,
            ),
          ),
        // 轮盘指示器
        Align(
          alignment: Alignment.topCenter,
          child: widget.indicator ??
              CustomPaint(
                size: const Size(30, 30),
                painter: TrianglePainter(),
              ),
        ),
        // 开始按钮
        widget.spinIcon != null
            ? Center(
                child: IconButton(
                  onPressed: () => startSpin(),
                  icon: widget.spinIcon!,
                ),
              )
            : Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextButton(
                    onPressed: () => startSpin(),
                    child: const Text('GO'),
                  ),
                ),
              ),
      ]),
    );
  }
}
