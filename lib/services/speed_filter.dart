class SpeedFilter {
  final int windowSize;
  final List<double> _speeds = [];

  SpeedFilter({this.windowSize = 5});

  double addSpeed(double speedKmh) {
    _speeds.add(speedKmh);

    if (_speeds.length > windowSize) {
      _speeds.removeAt(0);
    }

    return _speeds.reduce((a, b) => a + b) / _speeds.length;
  }
}
