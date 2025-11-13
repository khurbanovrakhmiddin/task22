// import 'package:flutter/material.dart';
//
// import '../../../../domain/entities/audio_entity.dart';
// import '../../audio_player/bloc/audio_player_bloc.dart';
// import '../../audio_player/player_page.dart';
// import 'audio_card.dart';
//
// class MainBody extends StatefulWidget {
//   final List<AudioMetadataEntity> audio;
//
//   const MainBody({super.key, required this.audio});
//
//   @override
//   State<MainBody> createState() => _MainBodyState();
// }
//
// class _MainBodyState extends State<MainBody> {
//   get audio => widget.audio;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: EdgeInsets.all(16),
//       itemCount: audio.length,
//       itemBuilder: (context, index) {
//         final audioEntity = audio[index];
//         final isCurrent = state.currentAudio == audioEntity;
//         final isLoadingCurrent = isCurrent && state.isLoading;
//
//         return AudioCard(
//           audio: audioEntity,
//           isCurrent: isCurrent,
//           isLoadingCurrent: isLoadingCurrent,
//           onTap: () {
//             if (!isCurrent) {
//               bloc.add(PlayAudioEvent(index));
//             }
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => PlayerPage()),
//             );
//           },
//           icon: IconButton(
//             onPressed: () => isCurrent
//                 ? bloc.add(PlayPauseAudioEvent())
//                 : bloc.add(PlayAudioEvent(index)),
//             icon: Icon(
//               isCurrent && state.playerStatus == PlayerStatus.play
//                   ? Icons.pause
//                   : Icons.play_arrow,
//               color: isCurrent ? Colors.blue : Colors.grey,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
