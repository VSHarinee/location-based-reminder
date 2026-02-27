import 'dart:math';

class PollingController {

  int computeInterval(double distance, double speedKmh) {

    final deltaD = max(10, min(300, 5 * sqrt(distance)));

    final vMps = max(speedKmh / 3.6, 1);

    final T = deltaD / vMps;

    return max(1, min(60, T.round()));
  }
}