import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/service/api_service.dart';
import 'package:video_player/video_player.dart';

class PreloadViewModel extends ChangeNotifier {
  List<String> _urls = [];
  List<String> get urls => _urls;

  Map<int, VideoPlayerController> _controllers = {};
  Map<int, VideoPlayerController> get controllers => _controllers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _focusedIndex = 0;
  int get focusedIndex => _focusedIndex;

  // Other methods and properties...

  void setAddUrls(List<String> urls) {
    _urls.addAll(urls);
    notifyListeners();
  }

  // void setVideoController(VideoPlayerController controller, int index) {
  //   _controllers.add(controller);
  //   notifyListeners();
  // }

  void setVideoController(VideoPlayerController controller, int index) {
    _controllers[index] = controller;
    notifyListeners();
  }

  Future<void> initializeControllerAtIndex(int index) async {
    if (index >= 0 && index < _urls.length) {
      final VideoPlayerController controller =
          VideoPlayerController.network(_urls[index]);

      setVideoController(controller, index);

      try {
        await controller.initialize();
        print('Controller initialized successfully for index $index');
      } catch (e) {
        print('Error initializing video at index $index: $e');
        _controllers.remove(index);
      }
      notifyListeners();
    } else {
      print('Invalid index: $index');
    }
  }

  setFocusedIndex(int index) {
    _focusedIndex = index;
    notifyListeners();
  }

  setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void onVideoIndexChanged(int index) {
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

      Future<void> playController() async {
        if (controller.value.isInitialized) {
          print("INDEX TWO IS::::${controller}");
          controller.play();
          // initializeControllerAtIndex(index + 1);
        } else {
          // Wait for initialization and then play
          await controller.initialize();
          print("INDEX TWO IS::::${controller}");
          controller.play();
        }
      }

      playController();
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
    notifyListeners();
  }

  // Other methods...

  // @override
  // void dispose() {
  //   for (final controller in _controllers) {
  //     controller?.dispose();
  //   }
  //   _controllers.clear();
  //   super.dispose();
  // }
}
