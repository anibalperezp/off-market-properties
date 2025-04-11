import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AdHelper {
  static encrypt.Encrypted? encrypted;
  static var decrypted;

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxxxx/xxxxxxxxxxxxxxxx';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxxxx/xxxxxxxxxxxxxxxx';
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get interestitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxx/xxxxxxxxxxxx';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-xxxxxxxxxxxxx/xxxxxxxxxxx';
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String getCallBack(version) {
    var ms = ((new DateTime.now()).millisecondsSinceEpoch / 1000).round();
    String keyText = ms.toString() + '#' + kPrimaryOFU;
    version = ms.toString().substring(0, 10) + '#' + version;
    //keyText = 'my 32 length key................';
    final key = encrypt.Key.fromUtf8(keyText);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    encrypted = encrypter.encrypt(version, iv: iv);
    return encrypted!.base64;
  }

  static Future<BitmapDescriptor> getClusterBitmap(int size,
      {String? text}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = headerColor; //amber

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: ui.TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3.2,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }
    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> getMarkerIcon(
      String textPrice, Color color, String imageAsset, bool isPrivate) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(pictureRecorder);

    // Define a size for your icon
    final double size = !isPrivate ? 151 : 165;

    // Load the image from assets
    final ByteData imageData =
        await rootBundle.load(imageAsset); // 'assets/images/icons/home_pin.png'
    final ui.Codec codec =
        await ui.instantiateImageCodec(imageData.buffer.asUint8List());
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    // Draw the image on the canvas
    final ui.Rect srcRect =
        ui.Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble());
    final ui.Rect dstRect = ui.Rect.fromLTWH(
        !isPrivate ? -4 : -4,
        !isPrivate ? 12 : 5,
        size,
        !isPrivate ? size - size / 3.9 : size - size / 5.4);
    canvas.drawImageRect(image, srcRect, dstRect, ui.Paint());

    // Define a Paint object to draw the price text
    final ui.TextStyle textStyle = ui.TextStyle(
      color: Colors.white,
      fontSize: !isPrivate ? size / 4.5 : size / 5.0,
      fontWeight: FontWeight.bold,
    );
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      maxLines: 1,
      fontSize: size / 5,
    ))
      ..pushStyle(textStyle)
      ..addText(textPrice);
    final ui.Paragraph paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: size));

    // Draw the price text on the canvas
    canvas.drawParagraph(
      paragraph,
      ui.Offset(size / 2 - paragraph.width / 2, size / 2 - size / 6),
    );

    // Define a Paint object to draw the icon
    final ui.Paint paint = ui.Paint();
    paint.color = Colors.transparent;
    paint.style = ui.PaintingStyle.fill;

    // Draw the icon on the canvas
    final ui.Path path = ui.Path();
    path.moveTo(size / 2 - size / 20, size / 2 - size / 12);
    path.lineTo(size / 2 + size / 20, size / 2 - size / 12);
    path.lineTo(size / 2, size / 2 + size / 12);
    path.close();
    canvas.drawPath(path, paint);

    // Convert the canvas to a PNG byte array
    final ui.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final ByteData? byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);

    // Return the PNG byte array as a BitmapDescriptor, which can be used as a marker icon
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
