import 'package:flutter/material.dart';
import '../theme/quire_tokens.dart';

/// Circle avatar with optional dashed ring for unread moments.
/// Strictly honors Quire invariant: Dashed ring instead of gradient.
class QuireCircleAvatar extends StatelessWidget {
  final String initials;
  final String? imageUrl;
  final Color backgroundColor;
  final double size;
  final bool hasUnreadStory;
  final bool isUserAddCircle;
  final VoidCallback? onTap;

  const QuireCircleAvatar({
    Key? key,
    required this.initials,
    this.imageUrl,
    this.backgroundColor = const Color(0xFFE5DDD0),
    this.size = 56.0,
    this.hasUnreadStory = false,
    this.isUserAddCircle = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget avatarContent;

    if (isUserAddCircle) {
      avatarContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: QuireTokens.s2Light,
          shape: BoxShape.circle,
          border: Border.all(color: QuireTokens.ruleLight, width: 1.0),
        ),
        child: const Icon(Icons.add, size: 22, color: QuireTokens.accentLight),
      );
    } else if (imageUrl != null) {
      avatarContent = ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitials(),
        ),
      );
    } else {
      avatarContent = _buildInitials();
    }

    if (hasUnreadStory) {
      avatarContent = CustomPaint(
        painter: DashedCirclePainter(
          color: QuireTokens.accentLight,
          gap: 4.0,
          strokeWidth: 2.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: avatarContent,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: avatarContent,
    );
  }

  Widget _buildInitials() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontFamily: QuireTokens.fontMono,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: QuireTokens.inkLight,
        ),
      ),
    );
  }
}

/// Custom painter for dashed circle ring (Quire signature: dashed ring instead of gradient).
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    const double dashLength = 6.0;
    final double circumference = 2 * 3.141592653589793 * radius;
    final int dashCount = (circumference / (dashLength + gap)).floor();
    final double actualGap = (circumference - (dashCount * dashLength)) / dashCount;

    double currentAngle = 0;
    final double dashAngle = (dashLength / circumference) * 2 * 3.141592653589793;
    final double gapAngle = (actualGap / circumference) * 2 * 3.141592653589793;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius - 1),
        currentAngle,
        dashAngle,
        false,
        paint,
      );
      currentAngle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
