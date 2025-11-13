import 'package:flutter/cupertino.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/bloc/audio_player_bloc.dart';

import '../../core/container/di/injector_impl.dart';
import '../../core/sevices/audio_session_service.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final AudioSessionService sessionService = di.get<AudioSessionService>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // Сохраняем при уходе в бэкграунд
        _saveSession();
        break;
      case AppLifecycleState.detached:
        // Сохраняем при закрытии приложения
        _saveSession();
        break;
      case AppLifecycleState.resumed:
        // Восстанавливаем при возвращении
        _restoreSession();
        break;
      default:
        break;
    }
  }

  void _saveSession() {
    // Получаем текущее состояние из BLoC и сохраняем
    final bloc = di.get<AudioPlayerBloc>();
    if (bloc.state.currentAudio != null) {
      sessionService.saveCurrentAudio(
        audio: bloc.state.currentAudio!,
        position: bloc.state.position,
        duration: bloc.state.duration,
        isPlaying: bloc.state.playerStatus == PlayerStatus.play,
      );
    }
  }

  void _restoreSession() {
  }
}
