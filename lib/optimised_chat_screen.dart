import 'dart:developer';

import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:transparent_image/transparent_image.dart';

import 'cubit/channel_cubit.dart';
import 'cubit/message_cubit.dart';

class OptimisedChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sendbird Optimised"),
        backgroundColor: const Color(0xFF1B4689),
      ),
      body: BlocBuilder<ChannelCubit, ChannelState>(
        builder: (context, state) {
          if (state is ChannelInitialisationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ChannelInitialisationError) {
            return Center(
              child: Text(
                  "Error While Initialising Sendbird Channel: ${state.msg}"),
            );
          } else if (state is ChannelLoaded) {
            context.read<MessageCubit>().initMessages(state.messages);
            return BlocBuilder<MessageCubit, List<dynamic>>(
              builder: (context, List<dynamic> a) {
                return Container(
                  color: Colors.amber,
                  child: DashChat(
                      avatarBuilder: (_) => const CircleAvatar(
                            backgroundColor: Colors.amber,
                          ),
                      scrollToBottomStyle: ScrollToBottomStyle(
                          backgroundColor: Colors.white,
                          bottom: 80,
                          textColor: const Color(0xFF1B4689)),
                      inputToolbarMargin:
                          const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      inputTextStyle: const TextStyle(fontSize: 18),
                      inputContainerStyle: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      // sendButtonBuilder: (trig) {
                      //   return Row(
                      //     children: [
                      //       IconButton(
                      //           onPressed: () {
                      //             context.read<MessageCubit>().showAttachment(
                      //                 context, state.groupChannel);
                      //           },
                      //           icon: const Icon(Icons.attach_file_rounded)),
                      //       IconButton(
                      //           iconSize: 45,
                      //           onPressed: () {
                      //             context
                      //                 .read<MessageCubit>()
                      //                 .sendMessage(message, state.groupChannel);
                      //           },
                      // onPressed: () {
                      //   log("message");
                      // context.read<MessageCubit>().sendMessage(
                      //     message, state.groupChannel)
                      // },
                      //           icon: Icon(Icons.arrow_forward_ios_rounded)),
                      //     ],
                      //   );
                      // },
                      messages: asDashChatMessages(a),
                      messageImageBuilder: (str, [ChatMessage? a]) {
                        return FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage, image: str!);
                      },
                      dateBuilder: (text) {
                        return Text(text);
                      },
                      user: asDashChatUser(SendbirdSdk().currentUser),
                      onSend: (newMessage) {
                        log(newMessage.text!, name: "onSend");
                        if (newMessage.text!.isNotEmpty) {
                          context.read<MessageCubit>().sendMessage(
                                BaseMessage(
                                  sender: Sender.fromUser(
                                    User(
                                      userId: state.userId.toString(),
                                      nickname: 'nickname',
                                    ),
                                    state.groupChannel,
                                  ),
                                  message: newMessage.text!,
                                  sendingStatus: MessageSendingStatus.succeeded,
                                  channelUrl: state.groupChannel.channelUrl,
                                  channelType: ChannelType.group,
                                ),
                                state.groupChannel,
                              );
                        }
                      }),
                );
              },
            );
          }
          throw Exception;
        },
      ),
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

  List<ChatMessage> asDashChatMessages(List<dynamic> messages) {
    return List.generate(messages.length, (index) {
      if (messages[index] is FileMessage) {
        final FileMessage file = messages[index];
        log(file.requireAuth.toString() + "---");
        return ChatMessage(
            text: file.message,
            image: file.secureUrl,
            user: asDashChatUser(file.sender));
      } else {
        final BaseMessage bMessage = messages[index];
        return ChatMessage(
            text: bMessage.message,
            user: asDashChatUser(bMessage.sender),
            createdAt: DateTime.now());
      }
    });
  }
}
