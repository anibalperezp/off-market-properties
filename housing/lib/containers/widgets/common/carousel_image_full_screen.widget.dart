import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:photo_view/photo_view.dart';

class CarouselImageFullScreen extends StatelessWidget {
  CarouselImageFullScreen({Key? key, this.imageList, this.index})
      : super(key: key);
  final List<String>? imageList;
  final int? index;

  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(''), backgroundColor: Colors.black),
      body: Container(
          color: buttonsColor,
          child: Builder(
            builder: (context) {
              final double height = MediaQuery.of(context).size.height;
              return CarouselSlider(
                carouselController: buttonCarouselController,
                options: CarouselOptions(
                  initialPage: index!,
                  height: height,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: false,
                ),
                items: imageList!
                    .map(
                      (item) => Container(
                        child: Center(
                          child: PhotoView(
                            imageProvider: NetworkImage(item),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          )),
    );
  }
}
