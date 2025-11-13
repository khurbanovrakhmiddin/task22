import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tak22_audio/src/presentation/bloc/audio_bloc.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/bloc/audio_player_bloc.dart';
import 'package:tak22_audio/src/presentation/pages/main/bloc/tab_bloc/tab_cubit.dart';
import 'package:tak22_audio/src/presentation/pages/main/main_page.dart';

import 'core/container/di/injector_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initial background
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.tak22_audio.channel.audio',
    androidNotificationChannelName: 'Tak22 Audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
    androidResumeOnClick: true,
    androidStopForegroundOnPause: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
    preloadArtwork: true,
    notificationColor: const Color(0xFF222222),
  );
  await init();
  WidgetsBinding.instance.addObserver(AppLifecycleListener());

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.get<AudioPlayerBloc>()..add(LoadAudiosEvent()),
        ),
        BlocProvider(create: (_) => di.get<AudioBloc>()),
        BlocProvider(create: (_) => di.get<TabCubit>()),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',

        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,

            iconTheme: IconThemeData(color: Colors.white),
          ),

          scaffoldBackgroundColor: Colors.black,

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        ),
        home: MainPage(),
      ),
    );
  }
}
