import 'package:another_flushbar/flushbar.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/main_screen/chat/chat_slidable_card.component.dart';
import 'package:zipcular/repository/provider/chat.provider.dart';

class ChatList extends StatefulWidget {
  ChatList({Key? key}) : super(key: key);

  @override
  __ChatListState createState() => __ChatListState();
}

class __ChatListState extends State<ChatList> {
  var conversations = List.empty(growable: true);
  var conversationsCache = List.empty(growable: true);
  String sChatId = '';
  String selectedFilter = 'All';
  List<String> selectedFilters = ['All'];
  List<String> filters = ['All', 'Marketplace', 'Connections'];
  List<String> itemsSort = ['All', 'Unread', 'Favorites'];
  String selectedSort = 'All';

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      Provider.of<ChatProvider>(context, listen: false)
          .fetchConversationsFromDatabase();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildComponent();
  }

  Widget buildComponent() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(color: Colors.white)),
        backgroundColor: headerColor,
        toolbarHeight: 45,
        actions: [],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          conversations = chatProvider.conversations;
          conversationsCache = chatProvider.conversationsCache;
          return conversationsCache.length == 0
              ? Center(
                  child: EmptyWidget(
                    hideBackgroundAnimation: false,
                    image: null,
                    packageImage: PackageImage.Image_3,
                    title: 'No chat history.',
                    subTitle: 'Contact sellers through chat',
                    titleTextStyle: TextStyle(
                      fontSize: 24,
                      color: Color(0xff9da9c7),
                      fontWeight: FontWeight.w500,
                    ),
                    subtitleTextStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xffabb8d6),
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Filter Chip
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: <Widget>[
                              PopupMenuButton<String>(
                                color: headerColor,
                                shadowColor: Colors.orange,
                                child: Container(
                                  height: 35,
                                  width: 40,
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    color: headerColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Icon(Icons.filter_list,
                                      color: Colors.white, size: 25),
                                ),
                                onSelected: (String result) {
                                  chatProvider.sortConv(this.selectedSort);
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  for (var item in itemsSort)
                                    PopupMenuItem<String>(
                                      onTap: () {
                                        this.selectedSort = item;
                                        chatProvider
                                            .sortConv(this.selectedSort);
                                      },
                                      value: item,
                                      child: Text(
                                          item == 'All'
                                              ? 'All'
                                              : 'Filter by ' + item,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                    ),
                                ],
                              ),
                              for (var filter in filters)
                                Container(
                                  margin: EdgeInsets.only(right: 7),
                                  child: FilterChip(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2),
                                    checkmarkColor: Colors.white,
                                    selectedColor: selectedFilter == filter
                                        ? headerColor
                                        : Colors.grey[200],
                                    backgroundColor: Colors.yellow[100],
                                    selected: selectedFilter == filter,
                                    label: Text(filter,
                                        style: TextStyle(
                                            color: selectedFilter == filter
                                                ? Colors.white
                                                : Colors.black)),
                                    onSelected: (bool value) {
                                      // Single selection
                                      setState(() {
                                        selectedFilters.clear();
                                        selectedFilter = filter;
                                      });
                                      chatProvider.filterConv(selectedFilter);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Chat list
                    conversations.length == 0
                        ? Expanded(
                            flex: 1,
                            child: Center(
                              child: Text('No conversations found.',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 22)),
                            ),
                          )
                        : Expanded(
                            flex: 1,
                            child: ListView.builder(
                              itemCount: conversations.length,
                              itemBuilder: (context, index) {
                                return ChatSlidableCard(
                                  chat: conversations[index],
                                  callbackRemoveChat: (value) async {
                                    await deleteChat(
                                        conversations[index].sChatId!,
                                        chatProvider);
                                  },
                                  callbackReportChat: (value) async {
                                    if (value.isNotEmpty) {
                                      await reportConversation(
                                          conversations[index].sChatId!,
                                          conversations[index].bIsFavorite!,
                                          true,
                                          true,
                                          value,
                                          chatProvider);
                                    }
                                  },
                                  callbackCancelReportChat: (value) async {
                                    await cancelReportConversation(
                                        conversations[index].sChatId!,
                                        conversations[index].bIsFavorite!,
                                        false,
                                        conversations[index].bIsReportedByMe!,
                                        '',
                                        chatProvider);
                                  },
                                  callbackFavotite: (value) async {
                                    await updateChat(
                                        conversations[index].sChatId!,
                                        value,
                                        conversations[index].bIsReported!,
                                        false,
                                        '',
                                        chatProvider);
                                  },
                                );
                              },
                            ),
                          ),
                  ],
                );
        },
      ),
    );
  }

  deleteChat(String sChatId, ChatProvider chatProvider) async {
    await chatProvider.deleteConversation(sChatId);
  }

  reportConversation(
      String sChatId,
      bool isFavorite,
      bool bIsReported,
      bool bIsReportedByMe,
      String reportDescription,
      ChatProvider chatProvider) async {
    await chatProvider.updateConversation(
        sChatId, isFavorite, bIsReported, bIsReportedByMe, reportDescription);
    if (reportDescription.isNotEmpty) {
      final flush = Flushbar(
        message: 'We will review it and we will take actions immediately.',
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
    }
  }

  cancelReportConversation(
      String sChatId,
      bool isFavorite,
      bool bIsReported,
      bool bIsReportedByMe,
      String reportDescription,
      ChatProvider chatProvider) async {
    bool result = await chatProvider.updateConversation(
        sChatId, isFavorite, bIsReported, bIsReportedByMe, reportDescription);
    if (result) {
      final flush = Flushbar(
        message: 'Conversation report cancelled successfully.',
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8.0),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.green,
        ),
        duration: Duration(seconds: 2),
        leftBarIndicatorColor: Colors.green,
      );
      flush.show(context);
    }
  }

  updateChat(
      String sChatId,
      bool isFavorite,
      bool bIsReported,
      bool bIsReportedByMe,
      String reportDescription,
      ChatProvider chatProvider) async {
    chatProvider.updateConversation(
        sChatId, isFavorite, bIsReported, bIsReportedByMe, reportDescription);
  }
}
