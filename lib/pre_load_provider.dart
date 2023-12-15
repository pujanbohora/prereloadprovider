import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/service/api_service.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';
import 'core/constants.dart';

class PreloadViewModel extends ChangeNotifier {
  List<String> _urls = [];
  List<String> get urls => _urls;

  List<VideoPlayerController?> _controllers = [];
  List<VideoPlayerController?> get controllers => _controllers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _focusedIndex = 0;
  int get focusedIndex => _focusedIndex;

  int _reloadCounter = 0;
  int get reloadCounter => _reloadCounter;

  setAddUrls(List<String> urls) {
    _urls.addAll(urls);
    notifyListeners();
  }

  setVideoController(VideoPlayerController controller, index) {
    // _controllers.length = index + 1;
    _controllers.add(controller);
    notifyListeners();
  }

  BuildContext? _context;
  BuildContext? get context => _context;

  setBuildContext(BuildContext context) {
    _context = context;
  }

  Future<VideoPlayerController?> initializeControllerAtIndex(int index) async {
    if (index >= 0 && index < _urls.length) {
      print("INITILIZED VIDEO INDEX IS::::${index}");
      final VideoPlayerController controller =
          VideoPlayerController.network(_urls[index]);

      print("VIDEO BEING INITILIZEDD::::${_urls[index]}");

      setVideoController(controller, index);

      // _controllers[index] = controller;
      try {
        await controller.initialize();
        print('Controller initialized successfully for index $index');
        return controller;
      } catch (e) {
        print('Error initializing video at index $index: $e');
        _controllers.remove(index);
        return null;
      }
    } else {
      print('Invalid index: $index');
      return null;
    }
  }

  void onVideoIndexChanged(int index) {
    // final bool shouldFetch = (index + kPreloadLimit) % kNextLimit == 0 &&
    //     _urls.length == index + kPreloadLimit;
    //
    // print("SHOULD FETCH:::$shouldFetch");
    //
    // if (shouldFetch) {
    //   createIsolate(index);
    // }

    print("ON VIDEO INDEX:::${index}");
    print("ON VIDEO focus index:::${_focusedIndex}");

    stopControllerAtIndex(_focusedIndex);

    if (index > _focusedIndex) {
      playNext(index);
    } else {
      playPrevious(index);
    }

    setFocusedIndex(index);
    notifyListeners();
  }

  void playControllerAtIndex(int index) {
    print("VIDEO PLAYING INDEX ARE::::${index}");
    if (_controllers.length > index && _controllers[index] != null) {
      final VideoPlayerController controller = _controllers[index]!;

      print("INDEX TWO IS::::${controller}");
      controller.play();
      notifyListeners();
    }
  }

  void stopControllerAtIndex(int index) {
    if (_urls.length > index && index >= 0) {
      final VideoPlayerController _controller = _controllers[index]!;
      _controller.pause();
      _controller.seekTo(const Duration());
      notifyListeners();
    }
  }

  void disposeControllerAtIndex(int index) {
    if (_urls.length > index && index >= 0) {
      final VideoPlayerController? _controller = _controllers[index];
      _controller?.dispose();

      if (_controller != null) {
        _controllers.remove(_controller);
      }
      notifyListeners();
    }
  }

  void playNext(int index) {
    print("PLAY INDEX::::${index}");
    stopControllerAtIndex(index - 1);
    disposeControllerAtIndex(index - 2);
    playControllerAtIndex(index);
    initializeControllerAtIndex(index + 1);
    notifyListeners();
  }

  void playPrevious(int index) async {
    print("PREVIOUD INDEX::::${index}");
    stopControllerAtIndex(index + 1);
    disposeControllerAtIndex(index + 2);
    playControllerAtIndex(index);
    initializeControllerAtIndex(index - 1);
    notifyListeners();
  }

  Future<void> initialize() async {
    setLoading(true);

    final List<String> _urls = await ApiService.getVideos();
    setAddUrls(_urls);

    print("ALL URLS LENGTH:::${_urls.length}");

    await initializeControllerAtIndex(0);
    playControllerAtIndex(0);

    await initializeControllerAtIndex(1);

    setLoading(false);
    setReloadCounter(_reloadCounter + 1);
    notifyListeners();
  }

  void updateUrls(List<String> newUrls) {
    // _urls.addAll(newUrls);
    setAddUrls(newUrls);
    initializeControllerAtIndex(_focusedIndex + 1);
    setReloadCounter(_reloadCounter + 1);
    setLoading(false);
    log('🚀🚀🚀 NEW VIDEOS ADDED');
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setFocusedIndex(int index) {
    _focusedIndex = index;
    notifyListeners();
  }

  void setReloadCounter(int counter) {
    _reloadCounter = counter;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      if (controller != null) {
        controller.dispose();
      }
    }
    _controllers.clear();
    super.dispose();
  }
}
