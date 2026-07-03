import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Approximates the handoff's `repeating-linear-gradient(45deg, chip Wpx,
/// elev Wpx 2*Wpx)` "map placeholder" stripe pattern — used by both
/// `TrackBookingScreen` (16px stripes) and `ProviderNavigateScreen` (18px
/// stripes), which use slightly different stripe widths per the handoff.
class DiagonalStripesPainter extends CustomPainter {
  const DiagonalStripesPainter({required this.chip, required this.elev, this.stripeWidth = 16});

  final Color chip;
  final Color elev;
  final double stripeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = elev);
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(math.pi / 4);
    final diag = size.width + size.height;
    final paint = Paint()..color = chip;
    final period = stripeWidth * 2;
    for (var x = -diag; x < diag; x += period) {
      canvas.drawRect(Rect.fromLTWH(x, -diag, stripeWidth, diag * 2), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DiagonalStripesPainter oldDelegate) =>
      oldDelegate.chip != chip || oldDelegate.elev != elev || oldDelegate.stripeWidth != stripeWidth;
}
