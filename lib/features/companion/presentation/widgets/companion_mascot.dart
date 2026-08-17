import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/companion_state.dart';

enum CompanionMascotPose { idle, feeding, playing, resting }

class CompanionMascot extends StatefulWidget {
  const CompanionMascot({
    required this.mood,
    required this.pose,
    this.width = 180,
    this.onTap,
    super.key,
  });

  final CompanionMood mood;
  final CompanionMascotPose pose;
  final double width;
  final Future<void> Function()? onTap;

  @override
  State<CompanionMascot> createState() => _CompanionMascotState();
}

class _CompanionMascotState extends State<CompanionMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final Animation<double> _breathingAnimation;

  Timer? _blinkTimer;
  Timer? _blinkEndTimer;

  bool _isBlinking = false;
  bool _isReacting = false;

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      vsync: this,
      duration: _breathingDuration,
    );

    _breathingAnimation = CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    );

    _breathingController.repeat(reverse: true);

    _scheduleBlink();
  }

  Duration get _breathingDuration {
    return switch (widget.pose) {
      CompanionMascotPose.resting => const Duration(milliseconds: 1800),
      CompanionMascotPose.idle => const Duration(milliseconds: 1350),
      CompanionMascotPose.feeding => const Duration(milliseconds: 800),
      CompanionMascotPose.playing => const Duration(milliseconds: 650),
    };
  }

  @override
  void didUpdateWidget(covariant CompanionMascot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pose == widget.pose) {
      return;
    }

    _breathingController.duration = _breathingDuration;

    _breathingController.repeat(reverse: true);

    if (widget.pose == CompanionMascotPose.resting) {
      _cancelBlink();

      if (_isBlinking) {
        setState(() {
          _isBlinking = false;
        });
      }

      return;
    }

    if (oldWidget.pose == CompanionMascotPose.resting) {
      _scheduleBlink();
    }
  }

  void _scheduleBlink() {
    if (widget.pose == CompanionMascotPose.resting) {
      return;
    }

    _blinkTimer?.cancel();

    final delay = Duration(milliseconds: 2200 + math.Random().nextInt(2600));

    _blinkTimer = Timer(delay, _startBlink);
  }

  void _startBlink() {
    if (!mounted || widget.pose == CompanionMascotPose.resting) {
      return;
    }

    setState(() {
      _isBlinking = true;
    });

    _blinkEndTimer?.cancel();

    _blinkEndTimer = Timer(const Duration(milliseconds: 140), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _isBlinking = false;
      });

      _scheduleBlink();
    });
  }

  Future<void> _handleTap() async {
    if (_isReacting || widget.pose == CompanionMascotPose.resting) {
      return;
    }

    setState(() {
      _isReacting = true;
    });

    try {
      final onTap = widget.onTap;

      if (onTap != null) {
        await onTap();
      }

      await Future<void>.delayed(const Duration(milliseconds: 420));
    } finally {
      if (mounted) {
        setState(() {
          _isReacting = false;
        });
      }
    }
  }

  void _cancelBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = null;

    _blinkEndTimer?.cancel();
    _blinkEndTimer = null;
  }

  @override
  void dispose() {
    _cancelBlink();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _breathingAnimation,
        builder: (context, child) {
          final progress = _breathingAnimation.value;

          final verticalOffset = switch (widget.pose) {
            CompanionMascotPose.resting => progress * 1.5,
            CompanionMascotPose.playing => progress * -3.0,
            CompanionMascotPose.feeding => progress * -1.5,
            CompanionMascotPose.idle => progress * -2.5,
          };

          final scaleY = switch (widget.pose) {
            CompanionMascotPose.resting => 1 + progress * 0.018,
            CompanionMascotPose.playing => 1 + progress * 0.025,
            CompanionMascotPose.feeding => 1 + progress * 0.018,
            CompanionMascotPose.idle => 1 + progress * 0.022,
          };

          return AnimatedSlide(
            offset: Offset(0, _isReacting ? -0.07 : 0),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: AnimatedScale(
              scale: _isReacting ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: Transform.translate(
                offset: Offset(0, verticalOffset),
                child: Transform.scale(
                  scaleX: 1,
                  scaleY: scaleY,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: SizedBox(
          width: widget.width,
          height: widget.width * 1.35,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.width, widget.width * 1.35),
                painter: _CompanionMascotPainter(
                  mood: widget.mood,
                  pose: widget.pose,
                  isBlinking: _isBlinking,
                ),
              ),
              if (_isReacting)
                const Positioned(
                  top: 0,
                  right: 4,
                  child: Text('💜', style: TextStyle(fontSize: 32)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanionMascotPainter extends CustomPainter {
  const _CompanionMascotPainter({
    required this.mood,
    required this.pose,
    required this.isBlinking,
  });

  final CompanionMood mood;
  final CompanionMascotPose pose;
  final bool isBlinking;

  static const Color _headColor = Color.fromARGB(255, 255, 199, 52);

  static const Color _bodyColor = Color.fromARGB(255, 105, 74, 190);

  static const Color _bodyDetailColor = Color.fromARGB(255, 78, 48, 155);

  static const Color _chestColor = Color.fromARGB(255, 255, 210, 68);

  static const Color _legColor = Color.fromARGB(255, 65, 65, 78);

  static const Color _shoeColor = Color.fromARGB(255, 99, 69, 196);

  static const Color _eyeColor = Color.fromARGB(255, 45, 34, 30);

  static const Color _mouthColor = Color.fromARGB(255, 90, 40, 35);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    final centerX = size.width / 2;

    final headRadius = size.width * 0.26;

    final headCenterY = size.height * 0.27;

    _drawLegs(canvas, paint, centerX, headCenterY, headRadius);

    _drawArms(canvas, paint, centerX, headCenterY, headRadius);

    _drawBody(canvas, paint, centerX, headCenterY, headRadius);

    _drawHead(canvas, paint, centerX, headCenterY, headRadius);

    _drawEyes(canvas, paint, centerX, headCenterY, headRadius);

    _drawMouth(canvas, paint, centerX, headCenterY, headRadius);
  }

  void _drawBody(
    Canvas canvas,
    Paint paint,
    double centerX,
    double headCenterY,
    double radius,
  ) {
    final bodyTop = headCenterY + radius * 0.72;

    final bodyBottom = bodyTop + radius * 1.15;

    paint
      ..style = PaintingStyle.fill
      ..color = _bodyColor;

    final bodyRect = Rect.fromLTRB(
      centerX - radius * 0.62,
      bodyTop,
      centerX + radius * 0.62,
      bodyBottom,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(radius * 0.32)),
      paint,
    );

    paint.color = _chestColor;

    canvas.drawCircle(
      Offset(centerX, bodyTop + radius * 0.55),
      radius * 0.18,
      paint,
    );

    paint
      ..color = _bodyDetailColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.07
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(centerX, bodyTop + radius * 0.10),
      Offset(centerX, bodyBottom - radius * 0.12),
      paint,
    );
  }

  void _drawArms(
    Canvas canvas,
    Paint paint,
    double centerX,
    double headCenterY,
    double radius,
  ) {
    final bodyTop = headCenterY + radius * 0.78;

    final shoulderY = bodyTop + radius * 0.22;

    final leftShoulderX = centerX - radius * 0.48;

    final rightShoulderX = centerX + radius * 0.48;

    var leftHandX = centerX - radius * 0.82;

    var rightHandX = centerX + radius * 0.82;

    var leftHandY = shoulderY + radius * 0.64;

    var rightHandY = shoulderY + radius * 0.64;

    switch (pose) {
      case CompanionMascotPose.feeding:
        leftHandX = centerX - radius * 0.38;

        rightHandX = centerX + radius * 0.38;

        leftHandY = shoulderY + radius * 0.45;

        rightHandY = shoulderY + radius * 0.45;

        break;

      case CompanionMascotPose.playing:
        leftHandY = shoulderY + radius * 0.22;

        rightHandY = shoulderY - radius * 0.05;

        break;

      case CompanionMascotPose.resting:
        leftHandY = shoulderY + radius * 0.76;

        rightHandY = shoulderY + radius * 0.76;

        break;

      case CompanionMascotPose.idle:
        break;
    }

    paint
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 0.25
      ..color = _bodyColor;

    canvas.drawLine(
      Offset(leftShoulderX, shoulderY),
      Offset(leftHandX, leftHandY),
      paint,
    );

    canvas.drawLine(
      Offset(rightShoulderX, shoulderY),
      Offset(rightHandX, rightHandY),
      paint,
    );

    paint
      ..style = PaintingStyle.fill
      ..color = _headColor;

    canvas.drawCircle(Offset(leftHandX, leftHandY), radius * 0.14, paint);

    canvas.drawCircle(Offset(rightHandX, rightHandY), radius * 0.14, paint);
  }

  void _drawLegs(
    Canvas canvas,
    Paint paint,
    double centerX,
    double headCenterY,
    double radius,
  ) {
    final bodyTop = headCenterY + radius * 0.72;

    final bodyBottom = bodyTop + radius * 1.15;

    final hipY = bodyBottom - radius * 0.06;

    final footY = hipY + radius * 0.86;

    var leftFootX = centerX - radius * 0.25;

    var rightFootX = centerX + radius * 0.25;

    if (pose == CompanionMascotPose.playing) {
      leftFootX -= radius * 0.14;

      rightFootX += radius * 0.14;
    }

    paint
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 0.24
      ..color = _legColor;

    canvas.drawLine(
      Offset(centerX - radius * 0.25, hipY),
      Offset(leftFootX, footY),
      paint,
    );

    canvas.drawLine(
      Offset(centerX + radius * 0.25, hipY),
      Offset(rightFootX, footY),
      paint,
    );

    paint
      ..style = PaintingStyle.fill
      ..color = _shoeColor;

    canvas.drawOval(
      Rect.fromLTRB(
        leftFootX - radius * 0.24,
        footY - radius * 0.08,
        leftFootX + radius * 0.30,
        footY + radius * 0.20,
      ),
      paint,
    );

    canvas.drawOval(
      Rect.fromLTRB(
        rightFootX - radius * 0.24,
        footY - radius * 0.08,
        rightFootX + radius * 0.30,
        footY + radius * 0.20,
      ),
      paint,
    );
  }

  void _drawHead(
    Canvas canvas,
    Paint paint,
    double centerX,
    double centerY,
    double radius,
  ) {
    paint
      ..style = PaintingStyle.fill
      ..color = _headColor;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    paint.color = const Color.fromARGB(75, 255, 255, 255);

    canvas.drawCircle(
      Offset(centerX - radius * 0.28, centerY - radius * 0.32),
      radius * 0.17,
      paint,
    );
  }

  void _drawEyes(
    Canvas canvas,
    Paint paint,
    double centerX,
    double centerY,
    double radius,
  ) {
    if (pose == CompanionMascotPose.resting || isBlinking) {
      _drawClosedEyes(canvas, paint, centerX, centerY, radius);

      return;
    }

    paint
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    canvas.drawOval(
      Rect.fromLTRB(
        centerX - radius * 0.57,
        centerY - radius * 0.30,
        centerX - radius * 0.04,
        centerY + radius * 0.22,
      ),
      paint,
    );

    canvas.drawOval(
      Rect.fromLTRB(
        centerX + radius * 0.04,
        centerY - radius * 0.30,
        centerX + radius * 0.57,
        centerY + radius * 0.22,
      ),
      paint,
    );

    var pupilOffset = 0.0;

    if (mood == CompanionMood.curious) {
      pupilOffset = radius * 0.05;
    }

    paint.color = _eyeColor;

    canvas.drawCircle(
      Offset(centerX - radius * 0.25 + pupilOffset, centerY),
      radius * 0.105,
      paint,
    );

    canvas.drawCircle(
      Offset(centerX + radius * 0.25 + pupilOffset, centerY),
      radius * 0.105,
      paint,
    );
  }

  void _drawClosedEyes(
    Canvas canvas,
    Paint paint,
    double centerX,
    double centerY,
    double radius,
  ) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 0.08
      ..color = _eyeColor;

    canvas.drawArc(
      Rect.fromLTRB(
        centerX - radius * 0.55,
        centerY - radius * 0.08,
        centerX - radius * 0.05,
        centerY + radius * 0.18,
      ),
      math.pi * 0.10,
      math.pi * 0.80,
      false,
      paint,
    );

    canvas.drawArc(
      Rect.fromLTRB(
        centerX + radius * 0.05,
        centerY - radius * 0.08,
        centerX + radius * 0.55,
        centerY + radius * 0.18,
      ),
      math.pi * 0.10,
      math.pi * 0.80,
      false,
      paint,
    );
  }

  void _drawMouth(
    Canvas canvas,
    Paint paint,
    double centerX,
    double centerY,
    double radius,
  ) {
    paint
      ..color = _mouthColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.09
      ..strokeCap = StrokeCap.round;

    if (mood == CompanionMood.sad && pose == CompanionMascotPose.idle) {
      canvas.drawArc(
        Rect.fromLTRB(
          centerX - radius * 0.30,
          centerY + radius * 0.28,
          centerX + radius * 0.30,
          centerY + radius * 0.62,
        ),
        math.pi * 1.12,
        math.pi * 0.76,
        false,
        paint,
      );

      return;
    }

    canvas.drawArc(
      Rect.fromLTRB(
        centerX - radius * 0.38,
        centerY + radius * 0.05,
        centerX + radius * 0.38,
        centerY + radius * 0.52,
      ),
      math.pi * 0.083,
      math.pi * 0.833,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CompanionMascotPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.pose != pose ||
        oldDelegate.isBlinking != isBlinking;
  }
}
