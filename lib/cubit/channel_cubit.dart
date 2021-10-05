import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

import '../repository/channel_repository.dart';

part 'channel_state.dart';

List<String> _toStringList(List<int> otherUserIds) {
  return otherUserIds.map((e) => e.toString()).toList();
}

class ChannelCubit extends Cubit<ChannelState> with ChannelEventHandler {
  final ChannelRepository _channelRepository;
  ChannelCubit(this._channelRepository) : super(ChannelInitial());

  void initialiseChannel(
    String appId,
    int userId,
    List<int> otherUserIds,
  ) async {
    emit(ChannelInitialisationLoading());
    // SendbirdSdk().addChannelEventHandler("chat", this);
    try {
      log(
        "Loading channel",
        name: "channel_cubit.dart",
        error: "This is error",
        level: 200,
        sequenceNumber: 1212,
      );
      List msgAndChannel = await _channelRepository.loadChannel(
          appId, userId.toString(), _toStringList(otherUserIds));
      //! Emit Data
      emit(ChannelLoaded(msgAndChannel[0], msgAndChannel[1], userId));
    } catch (e) {
      log(e.toString());
      emit(ChannelInitialisationError(e.toString()));
    }
  }
}
