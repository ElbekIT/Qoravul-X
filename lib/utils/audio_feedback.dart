import 'package:flutter/services.dart';

class AudioFeedback {
  static bool isVoiceEnabled = true;

  static void playTap(String label) {
    if (!isVoiceEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  static void playResult() {
    if (!isVoiceEnabled) return;
    HapticFeedback.mediumImpact();
  }

  static void playError() {
    if (!isVoiceEnabled) return;
    HapticFeedback.heavyImpact();
  }
}
