import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tak22_audio/src/presentation/pages/main/bloc/tab_bloc/tab_cubit.dart';
import 'package:tak22_audio/src/presentation/pages/main/widget/main_player_controller.dart';
import 'package:tak22_audio/src/presentation/pages/main/widget/main_body.dart';
import 'package:tak22_audio/src/presentation/pages/main/widget/search_widget.dart';
import 'package:tak22_audio/src/presentation/pages/setting/setting_page.dart';
import '../../bloc/audio_bloc.dart';
import '../audio_player/bloc/audio_player_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Ошибка: $errorMessage')),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Слушаем AudioPlayerBloc для ошибок воспроизведения
        BlocListener<AudioPlayerBloc, AudioPlayerState>(
          listener: (context, state) {
            if (state.hasError &&
                state.errorMessage != null &&
                state.errorMessage != '') {
              _showErrorSnackBar(state.errorMessage!);
              // Очищаем ошибку после показа
              context.read<AudioPlayerBloc>().add(ErrorStatusAudioEvent());
            }
          },
        ),

        // Слушаем AudioBloc для ошибок загрузки
        BlocListener<AudioBloc, AudioState>(
          listener: (context, state) {
            if (state.hasError) {
              _showErrorSnackBar(state.errorMessage ?? '');
              // Очищаем ошибку после показа
              context.read<AudioBloc>().add(ClearErrorEvent());
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tak22 Audio',style: TextStyle(color: Colors.white),),
          actions: [
            // Кнопка очистки поиска
            BlocBuilder<AudioBloc, AudioState>(
              builder: (context, state) {
                if (state.isSearching) {
                  return IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<AudioBloc>().add(ClearSearchEvent());
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
        bottomNavigationBar: BuildMainPlayerController(),

        //Vaqt yetmadi
        // bottomNavigationBar: BlocBuilder<TabCubit, TabState>(
        //   builder: (context, state) {
        //     return BottomNavigationBar(
        //       currentIndex: state.index,
        //
        //       onTap: (index) {
        //         context.read<TabCubit>().changeIndex(index);
        //       },
        //       items: [
        //         BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        //         BottomNavigationBarItem(
        //           icon: Icon(Icons.settings),
        //           label: "Settings",
        //         ),
        //       ],
        //     );
        //   },
        // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: BlocBuilder<TabCubit, TabState>(
          builder: (context, state) {
            return IndexedStack(
              index: state.index,
              children: [
                Column(
                  children: [
                    // Поисковая строка
                    SearchWidget(
                      controller: _searchController,
                      onChanged: _onChanged,
                    ),
                    Expanded(child: MainBody()),
                  ],
                ),
                SettingPage(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onChanged(String q) {
    context.read<AudioBloc>().add(SearchAudioEvent(q));
    ;
  }
}
