import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/notifications/notification.model.dart';
import 'package:zipcular/repository/provider/notifications.provider.dart';
import 'package:zipcular/repository/services/prod/common.service.dart';

class NotificationsTab extends StatefulWidget {
  NotificationsTab({Key? key}) : super(key: key);

  @override
  __NotificationsTabState createState() => __NotificationsTabState();
}

class __NotificationsTabState extends State<NotificationsTab> {
  CommonService services = new CommonService();
  bool check = false;
  bool loading = false;
  List<NotificationModel> notifications =
      List<NotificationModel>.empty(growable: true);

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
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: headerColor,
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, notificatioProvider, _) {
          this.notifications =
              notificatioProvider.notifications.cast<NotificationModel>();
          return this.notifications.length == 0
              ? Container(
                  margin: EdgeInsets.only(top: 60.0),
                  child: EmptyWidget(
                    image: null,
                    packageImage: PackageImage.Image_3,
                    title: 'Notifications',
                    subTitle: 'You have no notifications yet',
                    titleTextStyle: TextStyle(
                      fontSize: 24,
                      color: baseColor,
                      fontWeight: FontWeight.w500,
                    ),
                    subtitleTextStyle: TextStyle(
                      fontSize: 14,
                      color: Color(0xff9da9c7),
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: this.notifications.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            GFListTile(
                              onTap: () async {
                                notificatioProvider.updateNotificationAsRead(
                                    this.notifications[index].sCategory!,
                                    this.notifications[index].uNotificationId!);
                              },
                              color:
                                  this.notifications[index].bIsSeenIt == false
                                      ? Colors.white
                                      : Colors.grey[200],
                              padding: EdgeInsets.all(10),
                              titleText: this.notifications[index].sCategory,
                              subTitleText: this.notifications[index].sBody,
                              avatar: Container(
                                padding: EdgeInsets.only(right: 12.0),
                                decoration: new BoxDecoration(
                                  border: new Border(
                                    right: new BorderSide(
                                        width: 1.0, color: Colors.grey[300]!),
                                  ),
                                ),
                                child: Icon(
                                    this.notifications[index].bIsSeenIt == false
                                        ? Icons.fiber_new_rounded
                                        : this.notifications[index].sCategory ==
                                                'Listing'
                                            ? Icons.home
                                            : Icons.tips_and_updates_outlined,
                                    color:
                                        this.notifications[index].bIsSeenIt ==
                                                false
                                            ? Colors.red
                                            : Colors.grey[700],
                                    size: 30.0),
                              ),
                              icon: Icon(Icons.keyboard_arrow_right,
                                  color: Colors.red, size: 30.0),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Divider(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
