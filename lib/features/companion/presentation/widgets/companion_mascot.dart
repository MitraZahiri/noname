import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/companion_state.dart';

enum CompanionMascotPose { idle, feeding, playing, resting }

class CompanionMascot extends StatelessWidget {
  const CompanionMascot({
    required this.mood,
    required this.pose,
    this.width = 180,
    super.key,
  });

  final CompanionMood mood;
  final CompanionMascotPose pose;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 1.35,
      child: CustomPaint(
        painter: _CompanionMascotPainter(mood: mood, pose: pose),
      ),
    );
  }
}

class _CompanionMascotPainter extends CustomPainter {
  const _CompanionMascotPainter({required this.mood, required this.pose});

  final CompanionMood mood;
  final CompanionMascotPose pose;

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

      case CompanionMascotPose.playing:
        leftHandY = shoulderY + radius * 0.22;

        rightHandY = shoulderY - radius * 0.05;

      case CompanionMascotPose.resting:
        leftHandY = shoulderY + radius * 0.76;

        rightHandY = shoulderY + radius * 0.76;

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
    if (pose == CompanionMascotPose.resting) {
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
    return oldDelegate.mood != mood || oldDelegate.pose != pose;
  }
}
