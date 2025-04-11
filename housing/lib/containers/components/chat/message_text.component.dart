import 'package:flutter/material.dart';
import 'package:zipcular/commons/common.localization.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/chat/chat_message.model.dart';

class TextMessage extends StatefulWidget {
  const TextMessage({
    Key? key,
    this.message,
  }) : super(key: key);

  final ChatMessage? message;

  @override
  State<TextMessage> createState() => _TextMessageState();
}

class _TextMessageState extends State<TextMessage> {
  String formatedDate = '';

  @override
  void initState() {
    formatedDate = getTimeByLocation(widget.message!.sLastMessageCreatedTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        // show menu over chat message flutter

        _showPopupMenu();
      },
      child: Column(
        crossAxisAlignment: widget.message!.isSender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20 * 0.75,
              vertical: 20 / 2,
            ),
            decoration: BoxDecoration(
                color: widget.message!.isSender
                    ? headerColor.withOpacity(0.7)
                    : Colors.grey[300]!,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft:
                      Radius.circular(widget.message!.isSender ? 20 : 0),
                  bottomRight:
                      Radius.circular(widget.message!.isSender ? 0 : 20),
                )),
            child: Text(
              widget.message!.message,
              style: TextStyle(
                  color: widget.message!.isSender
                      ? Colors.white
                      : Colors.grey[800],
                  fontSize: 17),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              formatedDate,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPopupMenu() async {}
}
