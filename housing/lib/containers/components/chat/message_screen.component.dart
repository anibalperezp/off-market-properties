import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/chat/chat.model.dart';
import 'package:zipcular/models/chat/chat_message.model.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/provider/chat.provider.dart';
import 'message.component.dart';

class MessagesScreen extends StatefulWidget {
  final ChatUser? chat;
  final ValueChanged<bool>? callback;
  MessagesScreen(
      {Key? key,
      ChatUser? chat,
      ValueChanged<bool>? callback,
      String? accessToken})
      : chat = chat!,
        callback = callback!,
        super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List messages = List<ChatMessage>.empty(growable: true);
  final ScrollController _scrollController = ScrollController();
  TextEditingController messageController = new TextEditingController();
  bool loadingProfile = false;
  late CustomerModel customerProfile;
  late String name = 'User';
  bool validTextField = false;
  bool loading = false;

  @override
  void initState() {
    messageController.text = '';
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    Future.delayed(Duration.zero, () async {
      await loadChatMessages(chatProvider);
    });
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        messages = chatProvider.messages;
        return Scaffold(
          appBar: buildAppBar(chatProvider),
          body: loading == true
              ? ListView.builder(
                  itemCount: 12, // Number of shimmer items
                  itemBuilder: (context, index) {
                    bool isMe = index % 2 == 0; // Simulate alternating messages
                    return GFShimmer(
                      showShimmerEffect: true,
                      mainColor: Colors.grey[300]!,
                      secondaryColor: Colors.grey[100]!,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isMe)
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                radius: 20,
                              ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 18),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 150,
                                          height: 15,
                                          color: Colors.grey[300],
                                        ),
                                        SizedBox(height: 15),
                                        Container(
                                          width: 100,
                                          height: 15,
                                          color: Colors.grey[300],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Container(
                                      width: 50,
                                      height: 8,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isMe) SizedBox(width: 10),
                            if (isMe)
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                radius: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Column(
                  children: [
                    // CHAT LIST
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                          reverse: true, // Display messages from bottom to top
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return Message(
                                message: messages[index],
                                name: name,
                                pictureUser: widget.chat!.sUserProfilePicture);
                          },
                        ),
                      ),
                    ),

                    // CHAT LIST
                    // CHAT INPUT FIELD
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 32,
                            color: Color(0xFF087949).withOpacity(0.08),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20 * 0.75,
                                ),
                                decoration: BoxDecoration(
                                  color: baseColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sentiment_satisfied_alt_outlined,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withOpacity(0.64),
                                    ),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: TextField(
                                        enabled:
                                            widget.chat!.bIsReported == false,
                                        maxLines: 8,
                                        minLines: 1,
                                        controller: messageController,
                                        decoration: InputDecoration(
                                          hintText: "Send message",
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            validTextField = value.length > 0;
                                          });
                                        },
                                        onSubmitted: (value) {
                                          setState(() {
                                            validTextField = false;
                                          });
                                        },
                                      ),
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.send,
                                        color: validTextField
                                            ? headerColor
                                            : Colors.grey[500],
                                      ),
                                      onTap: () async {
                                        if (validTextField) {
                                          await sendMessage(chatProvider);
                                        } else {
                                          Flushbar flush = Flushbar(
                                            message: 'Please enter a message',
                                            flushbarStyle:
                                                FlushbarStyle.FLOATING,
                                            margin: EdgeInsets.all(8.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                            icon: Icon(
                                              Icons.info_outline,
                                              size: 28.0,
                                              color: headerColor,
                                            ),
                                            duration: Duration(seconds: 3),
                                            leftBarIndicatorColor: headerColor,
                                          );
                                          flush.show(context);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // CHAT INPUT FIELD
                  ],
                ),
        );
      },
    );
  }

  AppBar buildAppBar(ChatProvider chatProvider) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: headerColor,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              chatProvider.updateChatId('');
              Navigator.of(context).pop(true);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          CircleAvatar(
            backgroundImage: widget.chat!.sLystingProfilePicture!.isNotEmpty
                ? NetworkImage(widget.chat!.sLystingProfilePicture!)
                : widget.chat!.sMessageCategory == 'listing'
                    ? AssetImage('assets/images/house-test.jpeg')
                    : AssetImage('assets/images/friend1.jpg') as ImageProvider,
          ),
          SizedBox(width: 20 * 0.75),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chat!.sLystingName!,
                style: TextStyle(fontSize: 16, color: Colors.white),
              )
            ],
          )
        ],
      ),
      actions: [
        // IconButton(
        //   icon: Icon(Icons.local_phone),
        //   onPressed: () {},
        // ),
        // IconButton(
        //   icon: Icon(Icons.videocam),
        //   onPressed: () {},
        // ),
        // SizedBox(width: 20 / 2),
      ],
    );
  }

  sendMessage(ChatProvider chatProvider) async {
    Map<String, dynamic> jsonMessage = {
      "action": "sendPrivate",
      "sendTo": widget.chat!.sUserInvitationCode!,
      "sMessageContent": messageController.text,
      "sChatMessageType": "text",
      "sLystingId": widget.chat!.sLystingId!.toString(),
      "sMessageCategory": widget.chat!.sMessageCategory!,
      "sMessageSubCategory": widget.chat!.sMessageSubCategory!,
    };

    // Send Message websocket
    String send = json.encode(jsonMessage);
    await chatProvider.sendMessage(send, messageController.text, widget.chat!);

    // Scroll to the bottom of the list
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // Clean the Text Field
    setState(() {
      messageController.clear();
      validTextField = false;
    });
  }

  loadChatMessages(ChatProvider chatProvider) async {
    setState(() {
      loading = true;
    });
    await chatProvider.fetchMensagesFromDatabase(
        widget.chat!.sUserInvitationCode!, widget.chat!.sLystingId!);
    setState(() {
      loading = false;
    });
  }
}
