import 'reminder_engine.dart';

class TopKManager {

  List<Map<String, dynamic>> currentTopK = [];
  double lastGap = 0;

  final ReminderEngine _engine = ReminderEngine();

  void computeTopK(
      double userLat,
      double userLon,
      List<Map<String, dynamic>> reminders,
      ) {

    final distances = reminders.map((r) {
      final d = _engine.haversine(
        userLat,
        userLon,
        r["latitude"],
        r["longitude"],
      );

      return {...r, "distance": d};
    }).toList();

    distances.sort((a, b) =>
        a["distance"].compareTo(b["distance"]));

    if (distances.length >= 4) {
      lastGap = distances[3]["distance"] -
          distances[2]["distance"];
    }

    currentTopK = distances.take(3).toList();
  }

  bool shouldRecompute(double userMoved) {
    return userMoved >= 0.4 * lastGap;
  }
}