class ActivationController {

  DateTime? movingStart;
  DateTime? idleStart;

  bool isActive = false;

  void update(double avgSpeed) {
    final now = DateTime.now();

    if (avgSpeed > 3) {
      idleStart = null;

      movingStart ??= now;

      if (now.difference(movingStart!).inMinutes >= 2) {
        isActive = true;
      }
    } else {
      movingStart = null;

      idleStart ??= now;

      if (now.difference(idleStart!).inMinutes >= 10) {
        isActive = false;
      }
    }

    //isActive = true; // DEBUG ONLY
     }
  }