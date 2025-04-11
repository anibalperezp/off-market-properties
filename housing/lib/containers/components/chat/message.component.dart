import 'package:flutter/material.dart';
import 'package:zipcular/containers/components/chat/message_audio.component.dart';
import 'package:zipcular/models/chat/chat_message.model.dart';

import 'message_text.component.dart';
import 'message_video.component.dart';

class Message extends StatefulWidget {
  const Message({
    Key? key,
    this.message,
    this.name,
    this.pictureUser,
  }) : super(key: key);

  final ChatMessage? message;
  final String? name;
  final String? pictureUser;

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  @override
  Widget build(BuildContext context) {
    Widget messageContaint(ChatMessage message) {
      switch (message.messageType) {
        case ChatMessageType.text:
          return TextMessage(message: message);
        case ChatMessageType.audio:
          return AudioMessage(message: message);
        case ChatMessageType.video:
          return VideoMessage();
        default:
          return SizedBox();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: widget.message!.isSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!widget.message!.isSender) ...[
            Container(
              height: 40,
              width: 40,
              child: CircleAvatar(
                radius: 10,
                child: ClipOval(
                  child: widget.pictureUser!.isEmpty
                      ? Image.asset(
                          'assets/images/friend1.jpg',
                          height: 75,
                          width: 75,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          widget.pictureUser!,
                          height: 75,
                          width: 75,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            SizedBox(width: 20 / 2),
          ],
          Flexible(
            child: messageContaint(widget.message!),
          ),
          if (widget.message!.isSender)
            MessageStatusDot(status: widget.message!.messageStatus)
        ],
      ),
    );
  }
}

class MessageStatusDot extends StatelessWidget {
  final MessageStatus? status;

  const MessageStatusDot({Key? key, this.status}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Color dotColor(MessageStatus status) {
      switch (status) {
        case MessageStatus.not_sent:
          return Colors.red;
        case MessageStatus.not_view:
          return Colors.green.withOpacity(0.5);
        case MessageStatus.viewed:
          return Colors.green.withOpacity(0.5);
        default:
          return Colors.transparent;
      }
    }

    return Container(
      margin: EdgeInsets.only(left: 20 / 2),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: dotColor(status!),
        shape: BoxShape.circle,
      ),
      child: Icon(
        status == MessageStatus.not_sent ? Icons.close : Icons.done,
        size: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
