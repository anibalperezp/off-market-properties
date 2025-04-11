import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/listing/search/listing.dart';

class ImagesGallery extends StatefulWidget {
  ImagesGallery(
      {Key? key, this.listing, this.callback, this.callbackSelectedIndex})
      : super(key: key);
  Listing? listing;
  ValueChanged<Listing>? callback;
  ValueChanged<int>? callbackSelectedIndex;

  @override
  _ImagesGalleryState createState() {
    return new _ImagesGalleryState();
  }
}

class _ImagesGalleryState extends State<ImagesGallery> {
  final propTypes = [
    'Single Family',
    'Apartment',
    'Condo',
    'Townhome',
    'Lot',
    'Multi-Unit Complex'
  ];
  final ImagePicker _picker = ImagePicker();
  late BuildContext? dialogContext;
  List<File> localImages = List<File>.empty(growable: true);
  List<File> resultList = List<File>.empty(growable: true);

  @override
  void initState() {
    localImages = widget.listing!.imagesAssets != null
        ? widget.listing!.imagesAssets!
        : List.empty(growable: true);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ImagesGallery oldWidget) {
    localImages = oldWidget.listing!.imagesAssets != null
        ? oldWidget.listing!.imagesAssets!
        : List.empty(growable: true);
    if (widget.listing!.imagesAssets != null) {
      if (oldWidget.listing!.imagesAssets!.length !=
          widget.listing!.imagesAssets!.length) {
        setState(
          () {
            widget.listing = oldWidget.listing;
          },
        );
        localImages = oldWidget.listing!.imagesAssets! != null
            ? oldWidget.listing!.imagesAssets!
            : List.empty(growable: true);
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildOnlineGridView(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          crossAxisCount: 2,
        ),
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics(),
        itemCount: this.widget.listing!.sResourcesUrl.length,
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            children: <Widget>[
              Image.network(
                this.widget.listing!.sResourcesUrl[index],
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      index == 0
                          ? Container(
                              margin: EdgeInsets.only(left: 5, bottom: 5),
                              height: 24,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: headerColor.withOpacity(0.7),
                              ),
                              child: Center(
                                  child: Text("Cover Photo",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))))
                          : Container(),
                      GestureDetector(
                        onTap: () {
                          showDialogAlert(context, null,
                              this.widget.listing!.sResourcesUrl![index], true);
                        },
                        child: Container(
                            margin: EdgeInsets.only(right: 5, bottom: 5),
                            height: 24,
                            width: 21,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.white.withOpacity(0.7),
                            ),
                            child: Icon(
                              Icons.delete,
                              color: headerColor,
                              size: 21,
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ],
          );
        });
  }

  Widget buildGridView(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        crossAxisCount: 2,
      ),
      scrollDirection: Axis.vertical,
      physics: ScrollPhysics(),
      itemCount: localImages.length,
      itemBuilder: (BuildContext context, int index) {
        File asset = localImages[index];
        return Stack(
          children: <Widget>[
            Image.file(File(asset.path),
                height: 300, width: 300, fit: BoxFit.cover),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    index == 0
                        ? Visibility(
                            visible:
                                this.widget.listing!.sResourcesUrl.length == 0,
                            child: (Container(
                              margin: EdgeInsets.only(left: 5, bottom: 5),
                              height: 24,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: headerColor.withOpacity(0.7),
                              ),
                              child: Center(
                                child: Text(
                                  "Cover Photo",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                          )
                        : Container(),
                    GestureDetector(
                      onTap: () {
                        showDialogAlert(context, asset, '', false);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 5, bottom: 5),
                        height: 24,
                        width: 21,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white.withOpacity(0.7),
                        ),
                        child: Icon(
                          Icons.delete,
                          color: headerColor,
                          size: 21,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> loadAssets() async {
    List<XFile> images = await _picker.pickMultiImage();
    if (images.length > 0) {
      for (var image in images) {
        File? file = File(image!.path);
        resultList.add(file);
      }
    }

    setState(() {
      localImages = resultList;
      widget.listing!.imagesAssets = localImages;
      widget.callback!(widget.listing!);
      int index = propTypes.indexOf(this.widget.listing!.sPropertyType!);
      this.widget.callbackSelectedIndex!(index + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 3,
        ),
        this.widget.listing!.sResourcesUrl.length > 0
            ? buildUrlGrid()
            : Container(),
        this.widget.listing!.sResourcesUrl.length > 0
            ? Divider(
                color: Colors.grey[400],
                thickness: 1,
              )
            : Container(),
        buildInitialComponent()
      ],
    );
  }

  Widget buildUrlGrid() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            'Current Photos',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: () {
              loadAssets();
            },
            child: Container(
              margin: EdgeInsets.only(left: 10),
              height: 30,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: headerColor,
              ),
              child: Center(
                  child: Text("Add Photos",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold))),
            ),
          )
        ]),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
          child: buildOnlineGridView(context),
        ),
      ],
    );
  }

  Widget buildInitialComponent() {
    return Column(children: [
      Visibility(
          visible: this.widget.listing!.sResourcesUrl.length == 0,
          child: InkWell(
            onTap: () {
              loadAssets();
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 55,
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(169, 176, 185, 0.42),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Center(
                child: Text(
                  this.widget.listing!.sResourcesUrl.length > 0
                      ? 'Add Photos'
                      : 'Open Gallery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          )),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: buildGridView(context),
      )
    ]);
  }

  showDialogAlert(BuildContext context, File? asset, String url, bool isUrl) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel",
          style: TextStyle(
              color: headerColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        Navigator.pop(dialogContext!);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue",
          style: TextStyle(
              color: headerColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        setState(() {
          if (isUrl) {
            widget.listing!.sResourcesUrl.remove(url);
            widget.callback!(widget.listing!);
            int index = propTypes.indexOf(this.widget.listing!.sPropertyType!);
            this.widget.callbackSelectedIndex!(index + 1);
          } else {
            localImages.remove(asset);
            widget.listing!.imagesAssets = localImages;
            widget.callback!(widget.listing!);
            int index = propTypes.indexOf(this.widget.listing!.sPropertyType!);
            this.widget.callbackSelectedIndex!(index + 1);
          }
        });
        Navigator.pop(dialogContext!);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Center(
        child: Text('Delete Image'),
      ),
      content: Text('Would you like to remove this image?'),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }
}
