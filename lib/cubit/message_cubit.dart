import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/core/message/base_message.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:sendbird_started/repository/message_repository.dart';
import 'package:sendbird_started/module/attachment_module.dart';

class MessageCubit extends Cubit<List<dynamic>> with ChannelEventHandler {
  MessageCubit() : super([]);
  final MessageRepository _repository = MessageRepositoryImpl();
  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    log("Message Recieved --> ${message.data}");

    addMessage(message);
    super.onMessageReceived(channel, message);
  }

  initMessages(List<BaseMessage> message) {
    SendbirdSdk().addChannelEventHandler("chat", this);
    state.addAll(message);
    log(state.length.toString());
    emit(state);
  }

  addMessage(BaseMessage message) {
    log("Message added");
    emit([...state, message]);
  }

  sendMessage(BaseMessage message, GroupChannel channel) {
    _repository.sendMessage(message.message, channel);
    addMessage(message);
  }

  Future<void> showAttachment(
      BuildContext context, GroupChannel channel) async {
    final module = AttachmentModule(context: context);
    File file = await module.getFile();
    log("got file $file");
    FileMessage message = _repository.sendFile(file, channel);
    log("got message $message");
    addMessage(message);
    // onSendFileMessage(file);
  }

  @override
  Future<void> close() {
    SendbirdSdk().removeChannelEventHandler("chat");
    return super.close();
  }
}
