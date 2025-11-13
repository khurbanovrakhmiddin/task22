import 'package:shared_preferences/shared_preferences.dart';
import 'package:tak22_audio/core/sevices/audio_session_service.dart';
import 'package:tak22_audio/src/data/repository/auido_repository_impl.dart';
import 'package:tak22_audio/src/data/request/local/donwload_data_source_impl.dart';
import 'package:tak22_audio/src/domain/repository/audio_repository.dart';
import 'package:tak22_audio/src/domain/request/audio_remote_data_source.dart';
import 'package:tak22_audio/src/domain/usecases/get_audio_usecase.dart';
import 'package:tak22_audio/src/presentation/bloc/audio_bloc.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/bloc/audio_player_bloc.dart';
import '../../../dependencies/app_injection/injector.dart';
import '../../../src/data/request/local/audio_local_data_source_impl.dart';
import '../../../src/data/request/remote/audio_remote_data_source_impl.dart';
import '../../../src/domain/request/audio_local_data_source.dart';
import '../../../src/presentation/pages/main/bloc/tab_bloc/tab_cubit.dart';
import '../../sevices/player_service.dart';

final di = Injector();

//DI Container
Future<void> init() async {
  final prefs = await Future.microtask(
    () async => await SharedPreferences.getInstance(),
  );
  final _remote = AudioAssetsDataSource();
  final _local = AudioLocalDataSourceImpl(prefs);
  final _downloadDataSource = DownloadLocalDataSourceImpl();

  final _repository = AudioRepositoryImpl(_remote, _local);
  final _useCase = GetAudiosUseCase(_repository);
  final _audioService = AudioPlayerService();
  final _audioSessionService = AudioSessionService(prefs);
  final _bloc = AudioPlayerBloc(_useCase, _audioService, _audioSessionService);
  final _mainBloc = AudioBloc(_downloadDataSource);
  final _tabCubit = TabCubit();
  di.registerLazy<AudioLocalDataSource>(() => _local);
  di.registerLazy<DownloadLocalDataSourceImpl>(() => _downloadDataSource);
  di.registerLazy<AudioRemoteDataSource>(() => _remote);
  di.registerLazy<AudioRepository>(() => _repository);
  di.registerLazy<GetAudiosUseCase>(() => _useCase);
  di.registerLazy<AudioPlayerBloc>(() => _bloc);
  di.registerLazy<AudioBloc>(() => _mainBloc);
  di.registerLazy<TabCubit>(() => _tabCubit);
}
