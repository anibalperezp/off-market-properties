import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/chat/chat_card.component.dart';
import 'package:zipcular/containers/components/chat/message_screen.component.dart';
import 'package:zipcular/models/chat/chat.model.dart';
import 'package:zipcular/repository/provider/chat.provider.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class ChatSlidableCard extends StatefulWidget {
  ChatUser chat;
  final ValueChanged<String> callbackRemoveChat;
  final ValueChanged<String> callbackReportChat;
  final ValueChanged<String> callbackCancelReportChat;
  final ValueChanged<bool> callbackFavotite;
  ChatSlidableCard(
      {Key? key,
      ChatUser? chat,
      ValueChanged<String>? callbackRemoveChat,
      ValueChanged<String>? callbackReportChat,
      ValueChanged<String>? callbackCancelReportChat,
      ValueChanged<bool>? callbackFavotite})
      : chat = chat!,
        callbackRemoveChat = callbackRemoveChat!,
        callbackReportChat = callbackReportChat!,
        callbackCancelReportChat = callbackCancelReportChat!,
        callbackFavotite = callbackFavotite!,
        super(key: key);

  @override
  State<ChatSlidableCard> createState() => _ChatSlidableCardState();
}

class _ChatSlidableCardState extends State<ChatSlidableCard> {
  TextEditingController reportController = TextEditingController();
  UserRepository userRepository = new UserRepository();

  @override
  void dispose() {
    reportController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, _) {
      return Slidable(
        direction: Axis.horizontal,
        closeOnScroll: true,
        startActionPane: ActionPane(
          motion: OverflowBox(
              alignment: Alignment.center,
              maxWidth: double.infinity,
              child: ScrollMotion()),
          extentRatio: 0.20,
          openThreshold: 0.20,
          closeThreshold: 0.20,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 15),
              width: 100,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  SlidableAction(
                    flex: 1,
                    onPressed: (context) async {
                      if (widget.chat.bIsReported == false) {
                        await reportChat();
                      } else if (widget.chat.bIsReported &&
                          widget.chat.bIsReportedByMe) {
                        cancelReportChat();
                      }
                    },
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    icon: Icons.report,
                    label: widget.chat.bIsReported == false
                        ? 'Report'
                        : widget.chat.bIsReportedByMe
                            ? 'Cancel\nReport'
                            : 'Reported',
                  )
                ],
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: OverflowBox(
              alignment: Alignment.center,
              maxWidth: double.infinity, // Adjust this based on your needs
              child: ScrollMotion()),
          extentRatio: 0.20,
          openThreshold: 0.20,
          closeThreshold: 0.20,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 15),
              width: 100,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      deleteConversationChat();
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
            ),
          ],
        ),
        child: ChatCard(
          chat: widget.chat,
          press: () async {
            chatProvider.updateChatId(widget.chat.sChatId!);
            final accessToken = await userRepository.readKey('access_token');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessagesScreen(
                  accessToken: accessToken,
                  chat: widget.chat,
                  callback: (value) {},
                ),
              ),
            );
          },
          callbackFavotite: (value) {
            widget.callbackFavotite(value);
          },
        ),
      );
    });
  }

  reportChat() async {
    setState(() {
      reportController.text = ' ';
    });

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.info_outline,
                    size: 28.0,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  'Report Chat',
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          content: Container(
            margin: EdgeInsets.only(top: 10),
            width: double.maxFinite,
            height: MediaQuery.of(context).size.width * .65,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: reportController,
                    maxLines: 10,
                    autocorrect: true,
                    decoration: InputDecoration(
                      labelText: 'Why report this conversation?',
                      hintText: 'Please provide a reason for your report.',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Text(
                        'We will take actions immediately.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: [
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: buttonsColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: buttonsColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                Navigator.pop(context, '');
              },
            ),
            GestureDetector(
              onTap: () async {
                if (reportController.text.trim().isEmpty) {
                  final flush = Flushbar(
                    message: 'Please provide a reason for your report.',
                    flushbarStyle: FlushbarStyle.FLOATING,
                    margin: EdgeInsets.all(8.0),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    icon: Icon(
                      Icons.info_outline,
                      size: 28.0,
                      color: Colors.orange,
                    ),
                    duration: Duration(seconds: 2),
                    leftBarIndicatorColor: Colors.orange,
                  );
                  flush.show(context);
                } else {
                  String report = reportController.text.trim();
                  Navigator.pop(context);
                  if (report.isNotEmpty) {
                    widget.callbackReportChat(report);
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: headerColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  cancelReportChat() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(
            'Cancel Report',
            style: TextStyle(
                color: Colors.grey[800],
                fontSize: 20,
                fontWeight: FontWeight.bold),
          )),
          content: Container(
            margin: EdgeInsets.only(top: 10),
            width: double.maxFinite,
            height: MediaQuery.of(context).size.width * .15,
            child: Text(
              'Please confirm to cancel this report?',
              style: TextStyle(
                fontSize: 17.0,
                color: Colors.grey[700],
              ),
            ),
          ),
          actions: [
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: buttonsColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: buttonsColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                widget.callbackCancelReportChat(widget.chat.sChatId!);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: headerColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  "Confirm",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  deleteConversationChat() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(
            'Delete Conversation',
            style: TextStyle(
                color: Colors.grey[800],
                fontSize: 20,
                fontWeight: FontWeight.bold),
          )),
          content: Container(
            margin: EdgeInsets.only(top: 10),
            width: double.maxFinite,
            height: MediaQuery.of(context).size.width * .15,
            child: Text(
              'Please confirm to delete this conversation.',
              style: TextStyle(
                fontSize: 17.0,
                color: Colors.grey[700],
              ),
            ),
          ),
          actions: [
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: buttonsColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: buttonsColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            GestureDetector(
              onTap: () async {
                widget.callbackRemoveChat(widget.chat.sChatId!);
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: headerColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  "Confirm",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
