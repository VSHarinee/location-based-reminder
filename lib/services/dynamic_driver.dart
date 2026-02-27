import 'dart:async';
import 'package:geolocator/geolocator.dart';

import 'activation_controller.dart';
import 'speed_filter.dart';
import 'topk_manager.dart';
import 'polling_controller.dart';
import 'reminder_engine.dart';
import 'reminder_cache.dart';

class DynamicDriver {
  double debugInstantSpeed = 0;
  double debugAvgSpeed = 0;
  double debugGap = 0;
  double debugDistance = 0;
  double debugRadius = 0;
  double debugRemaining = 0;
  int debugPollingInterval = 0;
  String debugNearest = "";


  final SpeedFilter _speedFilter = SpeedFilter();
  final ActivationController _activation = ActivationController();
  final TopKManager _topK = TopKManager();
  final PollingController _polling = PollingController();
  final ReminderEngine _engine = ReminderEngine();

  StreamSubscription<Position>? _positionStream;
  Timer? _watcherTimer;

  List<Map<String, dynamic>> _cachedReminders = [];

  Position? _lastPosition;
  double _avgSpeed = 0;

  bool isEngineActive = false;
  String debugStatus = "Idle";

  Future<void> initialize() async {
    await ReminderCache.syncFromFirestore();  // 🔥 NEW
    _cachedReminders = await ReminderCache.loadReminders();
  }

  void start() {
    print("🚀 DynamicDriver started");
    print("Driver instance hash: ${hashCode}");
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy:LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen(_onLocationUpdate);
  }

  void stop() {
    _positionStream?.cancel();
    _watcherTimer?.cancel();
  }
  Future<void> refreshCache() async {
    _cachedReminders = await ReminderCache.loadReminders();
    print("🔄 Cache refreshed. Count: ${_cachedReminders.length}");
  }
  void _onLocationUpdate(Position position) {

    // ✅ Update instant speed properly
    debugInstantSpeed = position.speed * 3.6;

    // ✅ Update average speed properly
    debugAvgSpeed = _speedFilter.addSpeed(debugInstantSpeed);
    _avgSpeed = debugAvgSpeed;

    _activation.update(_avgSpeed);
    isEngineActive = _activation.isActive;

    print("Instant speed raw m/s: ${position.speed}");
    print("Instant speed km/h: $debugInstantSpeed");

    if (!isEngineActive) {
      debugStatus = "Inactive (Speed below threshold)";
      _watcherTimer?.cancel();
      return;
    }

    if (_cachedReminders.isEmpty) {
      print("Cached reminders count: ${_cachedReminders.length}");
      debugStatus = "No pending reminders";
      return;
    }

    if (_lastPosition != null) {
      final moved = _engine.haversine(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      if (_topK.currentTopK.isNotEmpty &&
          !_topK.shouldRecompute(moved)) {
        debugStatus = "Using existing Top-K";
      } else {
        _topK.computeTopK(
          position.latitude,
          position.longitude,
          _cachedReminders,
        );
        debugStatus = "Top-K recomputed";
      }
    } else {
      _topK.computeTopK(
        position.latitude,
        position.longitude,
        _cachedReminders,
      );
    }

    _lastPosition = position;

    _scheduleWatcher(position);
  }

  void _scheduleWatcher(Position currentPosition) {


    _watcherTimer?.cancel();

    if (_topK.currentTopK.isEmpty) return;

    final nearest = _topK.currentTopK.first;

    final distance = _engine.haversine(
      currentPosition.latitude,
      currentPosition.longitude,
      nearest["latitude"],
      nearest["longitude"],
    );

    final radius = _engine.dynamicRadius(_avgSpeed);

    final remaining = _engine.remainingDistance(distance, radius);

    final interval = _polling.computeInterval(
      remaining,
      _avgSpeed,
    );

    debugStatus =
    "Nearest: ${nearest["description"]} | "
        "Dist: ${distance.toStringAsFixed(1)}m | "
        "Radius: ${radius.toStringAsFixed(1)}m | "
        "Remaining: ${remaining.toStringAsFixed(1)}m | "
        "Polling: ${interval}s";

    _watcherTimer = Timer(Duration(seconds: interval), () {
      _triggerCheck(nearest);
    });

    debugDistance = distance;
    debugRadius = radius;
    debugRemaining = remaining;
    debugPollingInterval = interval;
    debugNearest = nearest["description"];
    debugGap = _topK.lastGap;
  }

  void _triggerCheck(Map<String, dynamic> reminder) async {

    final position = await Geolocator.getCurrentPosition();

    final distance = _engine.haversine(
      position.latitude,
      position.longitude,
      reminder["latitude"],
      reminder["longitude"],
    );

    final radius = _engine.dynamicRadius(_avgSpeed);

    if (distance <= radius) {
      _onTrigger(reminder);
    }
  }

  void _onTrigger(Map<String, dynamic> reminder) {

    debugStatus = "ALARM TRIGGERED: ${reminder["description"]}";

    if (onAlarm != null) {
      onAlarm!(reminder);
    }
  }

  void Function(Map<String, dynamic>)? onAlarm;
}