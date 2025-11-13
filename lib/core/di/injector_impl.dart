import 'package:tak22_audio/core/di/injector.dart';
import 'package:tak22_audio/core/sevices/audio_session_service.dart';
import 'package:tak22_audio/src/data/repository/auido_repository_impl.dart';
import 'package:tak22_audio/src/domain/repository/audio_repository.dart';
import 'package:tak22_audio/src/domain/request/audio_remote_data_source.dart';
import 'package:tak22_audio/src/domain/usecases/get_audio_usecase.dart';
import 'package:tak22_audio/src/presentation/bloc/audio_bloc.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/bloc/audio_player_bloc.dart';

import '../../src/data/request/remote/audio_remote_data_source_impl.dart';
import '../sevices/download_service.dart';
import '../sevices/player_service.dart';

final di = Injector();

Future<void> init() async {
  final _remote = AudioAssetsDataSource();
  final _downloadService = DownloadService();

  final _repository = AudioRepositoryImpl(_remote,_downloadService);
  final _useCase = GetAudiosUseCase(_repository);
  final _audioService = AudioPlayerService();
  final _audioSessionService = AudioSessionService();
  final _bloc = AudioPlayerBloc(_useCase,_audioService,_audioSessionService);
  final _mainBloc = AudioBloc(_repository);
  di.registerLazy<AudioRemoteDataSource>(() => _remote);
  di.registerLazy<AudioRepository>(() => _repository);
  di.registerLazy<GetAudiosUseCase>(() => _useCase);
  di.registerLazy<AudioPlayerBloc>(() => _bloc);
  di.registerLazy<AudioBloc>(() => _mainBloc);
}
