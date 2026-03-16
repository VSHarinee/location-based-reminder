import 'dart:math';

class PollingController {

  // This function decides how often the system should check the user's location again.
  // It returns the next polling interval in seconds.

  int computeInterval(double distance, double speedKmh) {

    // deltaD = target movement distance before next check
    // We calculate it using sqrt(distance) so that:
    // - when far from reminder → polling slower
    // - when near reminder → polling faster
    // We clamp the value between 10m and 300m to avoid extreme values
    final deltaD = max(10, min(300, 5 * sqrt(distance)));

    // Convert speed from km/h to m/s
    // Also ensure minimum speed = 1 m/s to avoid division by zero
    final vMps = max(speedKmh / 3.6, 1);

    // Compute time required to travel deltaD meters at current speed
    // T = distance / speed
    final T = deltaD / vMps;

    // Return polling interval in seconds
    // Minimum = 1 second
    // Maximum = 60 seconds
    // This prevents the system from polling too frequently or too slowly
    return max(1, min(60, T.round()));
  }
}