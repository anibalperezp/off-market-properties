import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:zipcular/commons/main.constants.global.dart';

class MapMaker extends CustomPainter {
  final Color color;
  final String textPrice;
  final IconData iconVisible;

  MapMaker(this.color, this.textPrice, this.iconVisible);

  void _buildMiniRect(Canvas canvas, Paint paint, double size) {
    paint.color = this.color;
    final rect = Rect.fromLTWH(0, 0, size, size);
    canvas.drawRect(rect, paint);
  }

  void _buildParagraph({
    @required Canvas? canvas,
    @required List<String>? texts,
    @required double? width,
    @required Offset? offset,
    Color color = Colors.black,
    double fontSize = 18,
    String? fontFamily,
    TextAlign textAlign = TextAlign.left,
  }) {
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        maxLines: 2,
        textAlign: textAlign,
      ),
    );
    builder.pushStyle(
      ui.TextStyle(
        fontWeight: FontWeight.w500,
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
      ),
    );

    builder.addText(texts![0]);

    if (texts.length > 1) {
      builder.pushStyle(ui.TextStyle(
        fontWeight: FontWeight.bold,
      ));
      builder.addText(texts[1]);
    }

    final ui.Paragraph paragraph = builder.build();

    paragraph.layout(ui.ParagraphConstraints(width: width!));
    canvas!.drawParagraph(
      paragraph,
      Offset(offset!.dx, offset.dy - paragraph.height / 2),
    );
  }

  _shadow(Canvas canvas, double witdh, double height) {
    final path = Path();
    path.lineTo(0, height);
    path.lineTo(witdh, height);
    path.lineTo(witdh, 0);
    path.close();
    canvas.drawShadow(path, Colors.black, 5, true);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    paint.color = buttonsColor;

    final height = size.height - 15;
    _shadow(canvas, size.width, height);

    final RRect rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      height,
      Radius.circular(0),
    );
    canvas.drawRRect(rrect, paint);

    final rect = Rect.fromLTWH(size.width / 2 - 2.5, height, 5, 15);

    canvas.drawRect(rect, paint);

    _buildMiniRect(canvas, paint, height);

    _buildParagraph(
      canvas: canvas,
      texts: [String.fromCharCode(iconVisible.codePoint)],
      width: height,
      fontSize: 45,
      textAlign: TextAlign.center,
      offset: Offset(0, height / 2),
      color: Colors.white,
      fontFamily: iconVisible.fontFamily,
    );

    _buildParagraph(
      canvas: canvas,
      texts: [this.textPrice],
      width: size.width - height - 20,
      offset: Offset(height + 10, height / 2),
      fontSize: 30,
      color: Colors.white,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
