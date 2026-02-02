class ReminderEngine {
  bool _alreadyTriggered = false;

  double getDynamicRadius(double avgSpeedKmh) {
    if (avgSpeedKmh < 2) return 30;
    if (avgSpeedKmh < 10) return 50;
    if (avgSpeedKmh < 25) return 100;
    if (avgSpeedKmh < 50) return 200;
    return 300;
  }

  bool shouldTrigger({
    required double distanceMeters,
    required double avgSpeedKmh,
  }) {
    if (_alreadyTriggered) return false;

    final radius = getDynamicRadius(avgSpeedKmh);

    if (distanceMeters <= radius) {
      _alreadyTriggered = true;
      return true;
    }
    return false;
  }

  void reset() {
    _alreadyTriggered = false;
  }
}
