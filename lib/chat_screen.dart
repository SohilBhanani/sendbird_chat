import 'dart:convert';
import 'dart:developer';

import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChatScreen extends StatefulWidget {
  final String appId;
  final int userId;
  final List<int> otherUserIds;

  const ChatScreen({
    required this.appId,
    required this.userId,
    required this.otherUserIds,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

List<String> toStringList(List<int> otherUserIds) {
  return otherUserIds.map((e) => e.toString()).toList();
}

class _ChatScreenState extends State<ChatScreen> with ChannelEventHandler {
  List<BaseMessage> _messages = [];
  GroupChannel? _channel;
  @override
  void initState() {
    load();
    SendbirdSdk().addChannelEventHandler("chat", this);
    super.initState();
  }

  @override
  void dispose() {
    SendbirdSdk().removeChannelEventHandler("chat");
    super.dispose();
  }

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    setState(() {
      _messages.add(message);
    });
    super.onMessageReceived(channel, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sendbird Chat"),
      ),
      body: DashChat(
          messages: asDashChatMessages(_messages),
          user: asDashChatUser(SendbirdSdk().currentUser),
          onSend: (newMessage) {
            final params = UserMessageParams(message: newMessage.text!);
            String message_type = "text";
            Map<String, dynamic> passingData = {
              "sender_name": "user ${widget.userId}",
              "mesaage_type": message_type
            };
            params.customType = 'text';
            params.data = json.encode(passingData);
            params.mentionType = MentionType.users;
            params.metaArrays = [
              MessageMetaArray(key: 'itemType', value: ['tablet'])
            ];
            var sentMessage = _channel!.sendUserMessage(params,
                onCompleted: (UserMessage message, error) {
              if (error != null) {
                print(error);
              } else {
                print("Success ${message.message}");
              }
            });
            setState(() {
              _messages.add(sentMessage);
            });
          }),
    );
  }

  ChatUser asDashChatUser(User? user) {
    if (user == null) {
      return ChatUser(
        uid: "",
        name: "",
        avatar: "",
      );
    } else {
      return ChatUser(
        uid: user.userId,
        name: user.nickname,
        avatar: user.profileUrl,
      );
    }
  }

  List<ChatMessage> asDashChatMessages(List<BaseMessage> messages) {
    return [
      for (BaseMessage sbm in messages)
        ChatMessage(
            text: sbm.message,
            user: asDashChatUser(sbm.sender),
            createdAt: DateTime.now())
    ];
  }

  Future<void> load() async {
    try {
      //! Init and connect Sendbird
      final SendbirdSdk sendbird = SendbirdSdk(appId: widget.appId);
      final _ = await sendbird.connect(widget.userId.toString());

      //! Get an Existing channel if exists
      final query = GroupChannelListQuery()
        ..limit = 1
        ..userIdsExactlyIn = toStringList(widget.otherUserIds);
      final List<GroupChannel> channels = await query.loadNext();

      GroupChannel aChannel;
      if (channels.isEmpty) {
        //! Create new Channel Otherwise
        aChannel = await GroupChannel.createChannel(
          GroupChannelParams()
            ..userIds =
                toStringList(widget.otherUserIds) + [widget.userId.toString()],
        );
      } else {
        aChannel = channels[0];
      }

      //! get Messages from Channel
      List<BaseMessage> messages = await aChannel.getMessagesByTimestamp(
          DateTime.now().microsecondsSinceEpoch * 1000, MessageListParams());

      //! Set Data
      setState(() {
        _messages = messages;
        _channel = aChannel;
      });
    } catch (e) {
      log(e.toString());
    }
  }
}
