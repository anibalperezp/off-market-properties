import 'package:empty_widget/empty_widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/listing/draft.dart';
import 'package:zipcular/models/listing/search_request.dart';
import 'draftCard.my_listings.component.dart';

class DraftstList extends StatefulWidget {
  List<Draft> drafs;
  bool loading;
  ValueChanged<String> callbackRemoveListing;
  DraftstList(
      {Key? key,
      List<Draft>? drafs,
      bool? loading,
      ValueChanged<String>? callbackRemoveListing})
      : drafs = drafs!,
        loading = loading!,
        callbackRemoveListing = callbackRemoveListing!,
        super(key: key);

  @override
  _DraftstListState createState() => _DraftstListState();
}

class _DraftstListState extends State<DraftstList> {
  bool loadingRemove = false;
  SearchRequest? request;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget widgetReturn = Container();
    try {
      widgetReturn = Container(
        color: Colors.white,
        child: widget.loading == true
            ? Center(
                child: CircularProgressIndicator(
                strokeWidth: 2,
                color: headerColor,
              ))
            : widget.drafs.length == 0
                ? Center(
                    child: EmptyWidget(
                    image: null,
                    hideBackgroundAnimation: true,
                    packageImage: PackageImage.Image_3,
                    title: 'No Draft Created',
                    subTitle: '',
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      color: baseColor,
                      fontWeight: FontWeight.w500,
                    ),
                    subtitleTextStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xffabb8d6),
                    ),
                  ))
                : Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: widget.drafs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return DraftCard(
                              draft: widget.drafs[index],
                              callbackRemoveListing: (id) {
                                widget.callbackRemoveListing(id);
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
      );
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }

    return widgetReturn;
  }
}
