import 'package:sendbird_sdk/sendbird_sdk.dart';

abstract class ChannelRepository {
  Future<List> loadChannel(
      String appId, String userId, List<String> otherUserIds);
}

class ChannelRepositoryImpl implements ChannelRepository {
  @override
  Future<List> loadChannel(
      String appId, String userId, List<String> otherUserIds) async {
    //! Init and connect Sendbird
    final SendbirdSdk sendbird = SendbirdSdk(appId: appId);
    final _ = await sendbird.connect(userId.toString());

    //! Get an Existing channel if exists
    final query = GroupChannelListQuery()
      ..limit = 1
      ..userIdsExactlyIn = otherUserIds;
    final List<GroupChannel> channels = await query.loadNext();

    GroupChannel aChannel;
    if (channels.isEmpty) {
      //! Create new Channel Otherwise
      aChannel = await GroupChannel.createChannel(
        GroupChannelParams()..userIds = otherUserIds + [userId.toString()],
      );
    } else {
      aChannel = channels[0];
    }

    //! get Messages from Channel
    List<BaseMessage> messages = await aChannel.getMessagesByTimestamp(
        DateTime.now().microsecondsSinceEpoch * 1000, MessageListParams());

    return [messages, aChannel];
  }
}
