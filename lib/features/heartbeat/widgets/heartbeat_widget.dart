import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/heartbeat_controller.dart';

/// HeartbeatWidget
/// Displays animated heartbeat with visual heart animation
/// Shows current pulse value with smooth counting animation
class HeartbeatWidget extends StatefulWidget {
  const HeartbeatWidget({super.key});

  @override
  State<HeartbeatWidget> createState() => _HeartbeatWidgetState();
}

class _HeartbeatWidgetState extends State<HeartbeatWidget>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Heartbeat animation - oscillates heart size
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    // Pulse wave animation - creates expanding rings
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HeartbeatController>(
      builder: (controller) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Pulse Waves Background
            SizedBox(
              width: 220.w,
              height: 220.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse wave
                  ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.5,
                      end: 1.5,
                    ).animate(_pulseController),
                    child: Container(
                      width: 220.w,
                      height: 220.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Middle pulse wave
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1.3).animate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeInCubic,
                      ),
                    ),
                    child: Container(
                      width: 220.w,
                      height: 220.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Inner circle with gradient background
                  Container(
                    width: 200.w,
                    height: 200.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red.shade400.withOpacity(0.3),
                          Colors.red.shade600.withOpacity(0.1),
                        ],
                      ),
                    ),
                    // Animated Heart Icon
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.8,
                        end: 1.0,
                      ).animate(_heartbeatController),
                      child: Icon(
                        Icons.favorite,
                        size: 100.sp,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Pulse Value Display
            Obx(
              () => Column(
                children: [
                  Text(
                    controller.animatedPulse.toString(),
                    style: TextStyle(
                      fontSize: 72.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'BPM',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HeartbeatAnimationPainter
/// Custom painter for drawing animated heartbeat waveform
class HeartbeatAnimationPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final List<int> pulseValues;

  HeartbeatAnimationPainter({
    required this.animation,
    required this.color,
    required this.pulseValues,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final pointsPerValue = size.width / pulseValues.length;

    // Draw waveform based on pulse values
    for (int i = 0; i < pulseValues.length; i++) {
      final x = i * pointsPerValue;
      final y = size.height / 2 - (pulseValues[i] / 100) * size.height / 2;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HeartbeatAnimationPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value;
  }
}
