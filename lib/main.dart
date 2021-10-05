import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repository/channel_repository.dart';
import 'cubit/channel_cubit.dart';
import 'cubit/message_cubit.dart';
import 'optimised_chat_screen.dart';

const String _appId = "YOUR APP ID HERE";
const int userId = 123;
const List<int> members = [123, 123, 123];

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChannelCubit>(
            create: (context) => ChannelCubit(ChannelRepositoryImpl())),
        BlocProvider<MessageCubit>(create: (context) => MessageCubit()),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<ChannelCubit>().initialiseChannel(
          _appId,
          //user
          userId,
          //List of rest
          members,
        );
    return OptimisedChatScreen();
  }
}
