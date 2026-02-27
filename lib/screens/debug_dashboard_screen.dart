import 'dart:async';
import 'package:flutter/material.dart';
import '../services/dynamic_driver.dart';

class DebugDashboardScreen extends StatefulWidget {
  final DynamicDriver driver;

  const DebugDashboardScreen({super.key, required this.driver});

  @override
  State<DebugDashboardScreen> createState() =>
      _DebugDashboardScreenState();
}

class _DebugDashboardScreenState
    extends State<DebugDashboardScreen> {

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 🔄 Refresh UI every second
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _infoCard(String title, String value,
      {Color? color}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                  fontSize: 16,
                  color: color ?? Colors.blue,
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final d = widget.driver;
    print("Debug screen driver hash: ${widget.driver.hashCode}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Engine Debug Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            _infoCard(
              "Engine Active",
              d.isEngineActive ? "YES" : "NO",
              color: d.isEngineActive
                  ? Colors.green
                  : Colors.red,
            ),

            _infoCard(
              "Instant Speed",
              "${d.debugInstantSpeed.toStringAsFixed(2)} km/h",
            ),

            _infoCard(
              "Average Speed (Last 5)",
              "${d.debugAvgSpeed.toStringAsFixed(2)} km/h",
            ),

            _infoCard(
              "Top-K Gap Value",
              d.debugGap.toStringAsFixed(2),
            ),

            _infoCard(
              "Nearest Reminder",
              d.debugNearest.isEmpty
                  ? "None"
                  : d.debugNearest,
            ),

            _infoCard(
              "Distance to Nearest",
              "${d.debugDistance.toStringAsFixed(2)} m",
            ),

            _infoCard(
              "Dynamic Radius R(v)",
              "${d.debugRadius.toStringAsFixed(2)} m",
            ),

            _infoCard(
              "Remaining Distance",
              "${d.debugRemaining.toStringAsFixed(2)} m",
            ),

            _infoCard(
              "Adaptive Polling Interval",
              "${d.debugPollingInterval}s",
            ),

            _infoCard(
              "Driver Status",
              d.debugStatus,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}