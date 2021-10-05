import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

abstract class MessageRepository {
  FileMessage sendFile(File file, GroupChannel channel);
  UserMessage sendMessage(String message, GroupChannel channel);
}

class MessageRepositoryImpl implements MessageRepository {
  @override
  FileMessage sendFile(File file, GroupChannel channel) {
    late FileMessage message;
    final params = FileMessageParams.withFile(
      file, /*name: fileName*/
    )..pushOption = PushNotificationDeliveryOption.suppress;
    const String messageType = "file";
    var passingData =
        "{\"sender_name\":\"senderName\",\"mesaage_type\":\"$messageType\"}";

    params.customType = 'file';
    params.data = passingData;
    params.mentionType = MentionType.users;
    params.metaArrays = [
      MessageMetaArray(key: 'itemType', value: ['tablet']),
      MessageMetaArray(key: 'linkTo', value: ['tablet']),
    ];
    // return params;
    message = channel.sendFileMessage(
      params,
      onCompleted: (msg, error) {
        message = msg;
      },
    );

    return message;
  }

  @override
  UserMessage sendMessage(String message, GroupChannel channel) {
    UserMessage msg;
    final params = UserMessageParams(message: message);
    String message_type = "text";
    Map<String, dynamic> passingData = {
      "sender_name": "name of sender",
      "mesaage_type": message_type
    };
    params.customType = 'text';
    params.data = json.encode(passingData);
    params.mentionType = MentionType.users;
    params.metaArrays = [
      MessageMetaArray(key: 'itemType', value: ['tablet'])
    ];
    msg = channel.sendUserMessage(params,
        onCompleted: (UserMessage message, error) {
      if (error != null) {
        log(error.toString());
      } else {
        log("Success ${message.message}");
        msg = message;
      }
    });
    return msg;
  }
}
