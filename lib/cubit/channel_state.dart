part of 'channel_cubit.dart';

abstract class ChannelState extends Equatable {
  const ChannelState();

  @override
  List<Object> get props => [];
}

class ChannelInitial extends ChannelState {
  @override
  List<Object> get props => [];
}

class ChannelInitialisationLoading extends ChannelState {
  @override
  List<Object> get props => [];
}

class ChannelInitialisationError extends ChannelState {
  const ChannelInitialisationError(this.msg);
  final String msg;
  @override
  List<Object> get props => [msg];
}

class ChannelLoaded extends ChannelState {
  const ChannelLoaded(this.messages, this.groupChannel, this.userId);
  final GroupChannel groupChannel;
  final List<BaseMessage> messages;
  final int userId;

  @override
  List<Object> get props => [messages, groupChannel, userId];
}
