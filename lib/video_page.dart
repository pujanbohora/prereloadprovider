import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_preload_videos/bloc/preload_bloc.dart';
import 'package:flutter_preload_videos/pre_load_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

// class VideoPageBloc extends StatelessWidget {
//   const VideoPage();
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: BlocBuilder<PreloadBloc, PreloadState>(
//         builder: (context, state) {
//           return PageView.builder(
//             itemCount: state.urls.length,
//             scrollDirection: Axis.vertical,
//             onPageChanged: (index) =>
//                 BlocProvider.of<PreloadBloc>(context, listen: false)
//                     .add(PreloadEvent.onVideoIndexChanged(index)),
//             itemBuilder: (context, index) {
//               // Is at end and isLoading
//               final bool _isLoading =
//                   (state.isLoading && index == state.urls.length - 1);
//
//               return state.focusedIndex == index
//                   ? VideoWidget(
//                       isLoading: _isLoading,
//                       controller: state.controllers[index]!,
//                     )
//                   : const SizedBox();
//             },
//           );
//         },
//       ),
//     );
//   }
// }

class VideoPageProvider extends StatelessWidget {
  const VideoPageProvider();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<PreloadViewModel>(
        builder: (context, state, child) {
          return PageView.builder(
            itemCount: state.urls.length,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) =>
                state.onVideoIndexChanged(index),
            itemBuilder: (context, index) {
              final bool _isLoading =
              (state.isLoading && index == state.urls.length - 1);

              return state.focusedIndex == index
                  ? VideoWidget(
                isLoading: _isLoading,
                controller: state.controllers[index]!,
              )
                  : const SizedBox();
            },
          );
        },
      ),
    );
  }
}

class VideoWidget extends StatelessWidget {
  const VideoWidget({
    Key? key,
    required this.isLoading,
    required this.controller,
  });

  final bool isLoading;
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: VideoPlayer(controller)),
        AnimatedCrossFade(
          alignment: Alignment.bottomCenter,
          sizeCurve: Curves.decelerate,
          duration: const Duration(milliseconds: 400),
          firstChild: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircularProgressIndicator(),
          ),
          secondChild: const SizedBox(),
          crossFadeState:
          isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ],
    );
  }
}

