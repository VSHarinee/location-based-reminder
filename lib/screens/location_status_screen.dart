
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../services/speed_filter.dart';
import '../services/distance_utils.dart';
import '../services/reminder_engine.dart';

class LocationStatusScreen extends StatefulWidget {
  const LocationStatusScreen({super.key});

  @override
  State<LocationStatusScreen> createState() => _LocationStatusScreenState();
}

class _LocationStatusScreenState extends State<LocationStatusScreen> {
  final _locationService = LocationService();
  final _speedFilter = SpeedFilter();
  final _reminderEngine = ReminderEngine();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  StreamSubscription<Position>? _positionSub;
  Position? _position;

  double _instantSpeed = 0;
  double _avgSpeed = 0;
  double _distanceMeters = 0;
  double _currentRadius = 0;

  double? _targetLat;
  double? _targetLng;

  bool _isNear = false;
  bool _bgStarted = false;

  // UI STATE FLAGS
  bool _permissionGranted = false;
  bool _loadingGps = true;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  // ================= GPS START ===================
  // void _startTracking() async {
  //   final hasPermission = await _locationService.ensurePermission();
  //
  //   if (!mounted) return;
  //
  //   if (!hasPermission) {
  //     setState(() {
  //       _permissionGranted = false;
  //       _loadingGps = false;
  //       _error = "❌ Location permission denied";
  //     });
  //     return;
  //   }
  //
  //   setState(() {
  //     _permissionGranted = true;
  //     _loadingGps = true;
  //     _error = "";
  //   });
  //
  //   _positionSub = _locationService.getPositionStream().listen(
  //         (position) {
  //       if (!mounted) return;
  //
  //       _position = position;
  //       _instantSpeed = position.speed * 3.6;
  //       _avgSpeed = _speedFilter.addSpeed(_instantSpeed);
  //
  //       _evaluateTrigger();
  //
  //       setState(() {
  //         _loadingGps = false;
  //       });
  //     },
  //     onError: (e) {
  //       setState(() {
  //         _error = "GPS Error: $e";
  //         _loadingGps = false;
  //       });
  //     },
  //   );
  // }
  void _startTracking() async {
    final hasPermission = await _locationService.ensurePermission();

    if (!mounted) return;

    if (!hasPermission) {
      setState(() {
        _permissionGranted = false;
        _loadingGps = false;
        _error = "❌ Location permission denied";
      });
      return;
    }

    setState(() {
      _permissionGranted = true;
      _loadingGps = true;
      _error = "";
    });

    // Cancel existing stream if any (defensive)
    await _positionSub?.cancel();
    _positionSub = null;

    // 🔹 START GPS STREAM (THROTTLED UI UPDATES)
    _positionSub = _locationService.getPositionStream().listen(
          (position) {
        if (!mounted) return;

        final newInstantSpeed = position.speed * 3.6;
        final newAvgSpeed = _speedFilter.addSpeed(newInstantSpeed);

        // 🔐 UPDATE UI ONLY IF SOMETHING MEANINGFUL CHANGED
        final shouldUpdateUI =
            _position == null ||
                (_position!.latitude - position.latitude).abs() > 0.00001 ||
                (_position!.longitude - position.longitude).abs() > 0.00001 ||
                (_avgSpeed - newAvgSpeed).abs() > 0.2;

        if (!shouldUpdateUI) return;

        _position = position;
        _instantSpeed = newInstantSpeed;
        _avgSpeed = newAvgSpeed;

        _evaluateTrigger();

        setState(() {
          _loadingGps = false;
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _error = "GPS Error: $e";
          _loadingGps = false;
        });
      },
    );

    // 🛡️ SAFETY TIMEOUT (PREVENTS INFINITE LOADING / BLACK UI)
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      if (_position == null) {
        setState(() {
          _loadingGps = false;
          _error = "⚠️ GPS not responding. Try moving or restart app.";
        });
      }
    });
  }



  // ================= GPS END ===================

  void _setTargetLocation() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);

    if (lat == null || lng == null) return;

    _reminderEngine.reset();
    _targetLat = lat;
    _targetLng = lng;

    _evaluateTrigger();
    setState(() {});
  }

  void _evaluateTrigger() {
    if (_position == null || _targetLat == null || _targetLng == null) {
      _isNear = false;
      return;
    }

    _distanceMeters = DistanceUtils.calculateDistance(
      _position!.latitude,
      _position!.longitude,
      _targetLat!,
      _targetLng!,
    );

    _currentRadius = _reminderEngine.getDynamicRadius(_avgSpeed);
    _isNear = _distanceMeters <= _currentRadius;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  // ================= UI ===================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Debug View")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _targetInput(),
              const SizedBox(height: 12),

              Expanded(
                child: Container(
                  color: Colors.white,
                  // 🚨 ADD THIS GUARD
                  child: _position == null
                      ? const Center(
                    child: Text(
                      "Waiting for GPS...",
                      style: TextStyle(fontSize: 16),
                    ),
                  )

                  // ===== PERMISSION SCREEN =====
                  : !_permissionGranted
                      ? Center(
                    child: Text(
                      _error.isEmpty
                          ? "Requesting location permission..."
                          : _error,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )

                  // ===== LOADING GPS SCREEN =====
                      : _loadingGps
                      ? const Center(child: CircularProgressIndicator())

                  // ===== MAIN DEBUG UI =====
                      : ListView(
                    children: [
                      _infoCard("Current Latitude",
                          _position!.latitude.toStringAsFixed(6)),
                      _infoCard("Current Longitude",
                          _position!.longitude.toStringAsFixed(6)),

                      if (_targetLat != null)
                        _infoCard("Target Latitude",
                            _targetLat!.toStringAsFixed(6)),
                      if (_targetLng != null)
                        _infoCard("Target Longitude",
                            _targetLng!.toStringAsFixed(6)),

                      if (_targetLat != null && _targetLng != null)
                        _infoCard("Distance to Target",
                            "${_distanceMeters.toStringAsFixed(2)} m"),

                      _infoCard("Instant Speed",
                          "${_instantSpeed.toStringAsFixed(2)} km/h"),
                      _infoCard("Average Speed",
                          "${_avgSpeed.toStringAsFixed(2)} km/h"),

                      if (_targetLat != null)
                        _infoCard("Trigger Radius",
                            "${_currentRadius.toStringAsFixed(0)} m"),

                      Card(
                        color: _isNear
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _isNear
                                ? "✅ Near the target location"
                                : "❌ Not near the target location",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _bgStarted
                            ? null
                            : () async {
                          // Stop UI GPS
                          await _positionSub?.cancel();
                          _positionSub = null;

                          // Let Android clean up GPS
                          await Future.delayed(const Duration(milliseconds: 500));

                          await FlutterBackgroundService().startService();

                          if (!mounted) return;
                          setState(() => _bgStarted = true);
                        },

                        child: Text(
                          _bgStarted
                              ? "Background Service Running"
                              : "Start Background Alarm Service",
                        ),
                      ),



                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== TARGET INPUT UI =====
  Widget _targetInput() {
    return Column(
      children: [
        TextField(
          controller: _latController,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Target Latitude",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _lngController,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Target Longitude",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _setTargetLocation,
          child: const Text("Set Target"),
        ),
      ],
    );
  }

  // ===== INFO CARD =====
  Widget _infoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
