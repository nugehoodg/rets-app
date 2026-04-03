import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class TemplateGenerator {
  static const double width = 340.0;
  static const double height = 520.0;

  static Future<Uint8List> generateTemplateBytes() async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width * 4, height * 4),
    );
    canvas.scale(4.0, 4.0);

    final paintBg = ui.Paint()..color = const Color(0xFF131313);
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), paintBg);

    final paintGuide = ui.Paint()
      ..color = Colors.white24
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintAccent = ui.Paint()
      ..color = Colors.cyan.withValues(alpha: 0.3)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 1. Outer Chassis Guide
    final chassisRRect = RRect.fromLTRBR(
      0,
      0,
      width,
      height,
      const Radius.circular(24),
    );
    canvas.drawRRect(chassisRRect, paintGuide);

    // 2. Cassette Bay Window
    final windowRect = const Rect.fromLTWH(24, 40, 292, 256);
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(12)),
      paintAccent,
    );
    _drawLabel(canvas, 'CASSETTE WINDOW AREA', 170, 168);

    // 3. Timeline Guide
    canvas.drawLine(const Offset(24, 320), const Offset(316, 320), paintGuide);
    _drawLabel(canvas, 'TIMELINE BAR OFFSET', 170, 310);

    // 4. Control Buttons Guides
    final btnY = 376.0; // 520 - 120 (height) - 24 (padding)
    _drawButtonGuide(canvas, 24, btnY, paintGuide, 'PREV');
    _drawButtonGuide(canvas, 142, btnY, paintGuide, 'PLAY/PAUSE');
    _drawButtonGuide(canvas, 260, btnY, paintGuide, 'NEXT');

    // 5. General Info
    _drawLabel(
      canvas,
      'ARCHIVIST V1 SKIN TEMPLATE // 340x520 PT',
      170,
      15,
      fontSize: 10,
      isBold: true,
    );
    _drawLabel(
      canvas,
      'DESIGN TIPS: Keep text 12pt+ for readability.',
      170,
      500,
      fontSize: 8,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      width.toInt() * 4,
      height.toInt() * 4,
    ); // 4x Super-sampling
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static void _drawButtonGuide(
    ui.Canvas canvas,
    double x,
    double y,
    ui.Paint paint,
    String label,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 56, 56),
        const Radius.circular(8),
      ),
      paint,
    );
    _drawLabel(canvas, label, x + 28, y + 68, fontSize: 7);
  }

  static void _drawLabel(
    ui.Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 9,
    bool isBold = false,
  }) {
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          )
          ..pushStyle(ui.TextStyle(color: Colors.white70))
          ..addText(text.toUpperCase());

    final paragraph = builder.build()
      ..layout(const ui.ParagraphConstraints(width: 300));
    canvas.drawParagraph(paragraph, Offset(x - 150, y));
  }
}
