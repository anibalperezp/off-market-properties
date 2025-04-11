import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zipcular/commons/common.localization.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/chat/chat.model.dart';

class ChatCard extends StatefulWidget {
  final ChatUser chat;
  final VoidCallback press;
  final ValueChanged<bool> callbackFavotite;

  ChatCard(
      {Key? key,
      ChatUser? chat,
      VoidCallback? press,
      ValueChanged<bool>? callbackFavotite})
      : chat = chat!,
        press = press!,
        callbackFavotite = callbackFavotite!,
        super(key: key);

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  String fromNow = '';
  late ConfettiController? _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 2));
    setState(() {
      fromNow = getTimeByLocation(widget.chat.sLastMessageCreatedTime);
    });
  }

  @override
  void dispose() {
    _controllerCenter!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.press,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20 * 0.75),
        child: Column(
          children: [
            Row(
              children: [
                Visibility(
                    child: Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Icon(
                        Icons.info_outline,
                        size: 40.0,
                        color: Colors.orange,
                      ),
                    ),
                    visible: widget.chat.bIsReported),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.chat.bIsFavorite = !widget.chat.bIsFavorite;
                        });
                        if (widget.chat.bIsFavorite) {
                          _controllerCenter!.play();
                        }
                        widget.callbackFavotite(widget.chat.bIsFavorite);
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        child: widget.chat.sLystingProfilePicture!.isNotEmpty
                            ? CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                    widget.chat.sLystingProfilePicture!),
                              )
                            : CircleAvatar(
                                radius: 24,
                                backgroundImage: widget.chat.sMessageCategory ==
                                        'listing'
                                    ? AssetImage(
                                        'assets/images/house-test.jpeg')
                                    : AssetImage('assets/images/friend1.jpg'),
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onLongPress: () async {
                          setState(() {
                            widget.chat.bIsFavorite = !widget.chat.bIsFavorite;
                          });
                          if (widget.chat.bIsFavorite) {
                            _controllerCenter!.play();
                          }
                          widget.callbackFavotite(widget.chat.bIsFavorite);
                          // Adding flushbar
                        },
                        child: ConfettiWidget(
                          child: Container(
                            margin: EdgeInsets.only(right: 0, bottom: 1),
                            height: 21,
                            width: 20,
                            child: this.widget.chat.bIsFavorite
                                ? Icon(
                                    Icons.favorite,
                                    color: headerColor,
                                    size: 24,
                                  )
                                : Icon(
                                    FontAwesomeIcons.heart,
                                    color: headerColor,
                                    size: 24,
                                  ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  width: 1),
                            ),
                          ),
                          confettiController: _controllerCenter!,
                          blastDirectionality: BlastDirectionality
                              .explosive, // don't specify a direction, blast randomly
                          shouldLoop:
                              false, // start again as soon as the animation is finished
                          colors: const [
                            Colors.green,
                            Colors.blue,
                            Colors.pink,
                            Colors.orange,
                            Colors.purple
                          ], // manually specify the colors to be used
                          // define a custom shape/path.
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          widget.chat.sLystingName!,
                          style: TextStyle(
                              color: widget.chat.sMessageStatus! == 'not_view'
                                  ? chatDarkTitleColor
                                  : chatTitleColor,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                              fontWeight:
                                  widget.chat.sMessageStatus! == 'not_view'
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                        ),
                        SizedBox(height: 2),
                        Opacity(
                          opacity: 0.64,
                          child: Text(
                            '"' + widget.chat.sLastMessageContent! + '"',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    widget.chat.sMessageStatus! == 'not_view'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color: widget.chat.sMessageStatus! == 'not_view'
                                    ? chatDarkMessageColor
                                    : chatMessageColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.64,
                  child: Text(fromNow, style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.only(top: 0, bottom: 0),
              margin: EdgeInsets.only(top: 0, bottom: 0),
              width: MediaQuery.of(context).size.width,
              height: 0.5,
              decoration: BoxDecoration(
                color: headerColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
