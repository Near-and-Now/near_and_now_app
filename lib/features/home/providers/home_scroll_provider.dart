import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScrollNotifier extends Notifier<ScrollController?> {
  @override
  ScrollController? build() {
    return null;
  }

  void setController(ScrollController controller) {
    state = controller;
  }

  void scrollToTop() {
    if (state != null && state!.hasClients) {
      state!.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void clearController() {
    state = null;
  }
}

final homeScrollNotifierProvider = NotifierProvider<HomeScrollNotifier, ScrollController?>(
  () => HomeScrollNotifier(),
);
