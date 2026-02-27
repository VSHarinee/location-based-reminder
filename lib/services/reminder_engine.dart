// class ReminderEngine {
//   bool _alreadyTriggered = false;
//
//   double getDynamicRadius(double avgSpeedKmh) {
//     if (avgSpeedKmh < 2) return 30;
//     if (avgSpeedKmh < 10) return 50;
//     if (avgSpeedKmh < 25) return 100;
//     if (avgSpeedKmh < 50) return 200;
//     return 300;
//   }
//
//   bool shouldTrigger({
//     required double distanceMeters,
//     required double avgSpeedKmh,
//   }) {
//     if (_alreadyTriggered) return false;
//
//     final radius = getDynamicRadius(avgSpeedKmh);
//
//     if (distanceMeters <= radius) {
//       _alreadyTriggered = true;
//       return true;
//     }
//     return false;
//   }
//
//   void reset() {
//     _alreadyTriggered = false;
//   }
// }
import 'dart:math';

class ReminderEngine {

  double dynamicRadius(double avgSpeedKmh) {
    return 16.5 * avgSpeedKmh + 50;
  }

  double haversine(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const R = 6371000; // meters

    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_deg2rad(lat1)) *
                cos(_deg2rad(lat2)) *
                sin(dLon / 2) *
                sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  double remainingDistance(double distance, double radius) {
    return max(0, distance - radius);
  }

  double _deg2rad(double deg) => deg * pi / 180;
}