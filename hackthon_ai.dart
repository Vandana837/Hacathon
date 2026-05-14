import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const RescueAIApp());
}

class RescueAIApp extends StatelessWidget {
  const RescueAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Rescue Route AI",
      theme: ThemeData.dark(),
      home: const RescueHomePage(),
    );
  }
}

class RescueHomePage extends StatefulWidget {
  const RescueHomePage({super.key});

  @override
  State<RescueHomePage> createState() => _RescueHomePageState();
}

class _RescueHomePageState extends State<RescueHomePage> {
  final Random random = Random();

  final LatLng cityCenter = LatLng(13.0827, 80.2707);

  bool simRunning = false;
  bool showHazards = true;

  String mode = "Rescue";

  int rescued = 0;

  Timer? distressTimer;
  Timer? movementTimer;
  Timer? hazardTimer;

  List<Map<String, dynamic>> teams = [
    {
      "id": 1,
      "name": "Alpha Team",
      "pos": LatLng(13.0827, 80.2707),
      "color": Colors.greenAccent,
      "status": "Active",
    },
    {
      "id": 2,
      "name": "Beta Team",
      "pos": LatLng(13.065, 80.25),
      "color": Colors.cyanAccent,
      "status": "Active",
    },
    {
      "id": 3,
      "name": "Gamma Team",
      "pos": LatLng(13.1, 80.29),
      "color": Colors.amberAccent,
      "status": "Standby",
    },
  ];

  List<Map<String, dynamic>> hazards = [
    {
      "id": 1,
      "pos": LatLng(13.078, 80.265),
      "radius": 800.0,
      "color": Colors.red,
      "label": "Flood Zone",
    },
    {
      "id": 2,
      "pos": LatLng(13.09, 80.255),
      "radius": 600.0,
      "color": Colors.orange,
      "label": "Fire Zone",
    },
  ];

  List<Map<String, dynamic>> distressLocations = [];

  List<Map<String, dynamic>> routes = [];

  List<String> logs = [
    "🚨 Rescue AI System Initialized",
  ];

  int? activeRoute;

  final List<String> areas = [
    "Adyar",
    "Velachery",
    "Tambaram",
    "T Nagar",
    "OMR",
    "Guindy",
    "Anna Nagar",
  ];

  @override
  void dispose() {
    distressTimer?.cancel();
    movementTimer?.cancel();
    hazardTimer?.cancel();
    super.dispose();
  }

  // ================= START SIMULATION =================

  void startSimulation() {
    setState(() {
      simRunning = true;
    });

    // DISTRESS CALLS
    distressTimer = Timer.periodic(
      const Duration(seconds: 4),
          (_) {
        generateDistress();
      },
    );

    // TEAM MOVEMENT
    movementTimer = Timer.periodic(
      const Duration(seconds: 2),
          (_) {
        moveTeams();
      },
    );

    // HAZARD EXPANSION
    hazardTimer = Timer.periodic(
      const Duration(seconds: 6),
          (_) {
        expandHazards();
      },
    );
  }

  // ================= STOP SIMULATION =================

  void stopSimulation() {
    distressTimer?.cancel();
    movementTimer?.cancel();
    hazardTimer?.cancel();

    setState(() {
      simRunning = false;
    });
  }

  // ================= GENERATE DISTRESS =================

  void generateDistress() {
    final newDistress = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "pos": LatLng(
        13.05 + random.nextDouble() * 0.08,
        80.23 + random.nextDouble() * 0.08,
      ),
      "people": random.nextInt(30) + 1,
      "area": areas[random.nextInt(areas.length)],
    };

    distressLocations.insert(0, newDistress);

    if (distressLocations.length > 10) {
      distressLocations.removeLast();
    }

    logs.insert(
      0,
      "🚨 Distress signal from ${newDistress["area"]}",
    );

    if (logs.length > 10) {
      logs.removeLast();
    }

    rescued += random.nextInt(4);

    createRoutes(newDistress);

    setState(() {});
  }

  // ================= CREATE ROUTES =================

  void createRoutes(Map<String, dynamic> distress) {
    routes.clear();

    for (int i = 0; i < teams.length; i++) {
      final team = teams[i];

      routes.add({
        "id": team["id"],
        "label": i == 0
            ? "AI Optimized"
            : i == 1
            ? "Fastest"
            : "Safest",
        "color": i == 0
            ? Colors.greenAccent
            : i == 1
            ? Colors.cyanAccent
            : Colors.amberAccent,
        "points": generateRoute(
          team["pos"],
          distress["pos"],
        ),
        "time": "${5 + random.nextInt(10)} min",
        "safety": "${70 + random.nextInt(30)}%",
        "distance":
        "${(random.nextDouble() * 5 + 1).toStringAsFixed(1)} km",
      });
    }

    activeRoute = routes.first["id"];
  }

  // ================= GENERATE ROUTE =================

  List<LatLng> generateRoute(
      LatLng start,
      LatLng end,
      ) {
    return [
      start,
      LatLng(
        (start.latitude + end.latitude) / 2,
        (start.longitude + end.longitude) / 2,
      ),
      end,
    ];
  }

  // ================= MOVE TEAMS =================

  void moveTeams() {
    for (var team in teams) {
      final LatLng pos = team["pos"];

      team["pos"] = LatLng(
        pos.latitude +
            (random.nextDouble() - 0.5) * 0.003,
        pos.longitude +
            (random.nextDouble() - 0.5) * 0.003,
      );
    }

    setState(() {});
  }

  // ================= EXPAND HAZARDS =================

  void expandHazards() {
    for (var hazard in hazards) {
      hazard["radius"] += random.nextDouble() * 80;
    }

    logs.insert(
      0,
      "⚠ Hazard zone expanded",
    );

    setState(() {});
  }

  // ================= BLOCK ROAD =================

  void blockRoad() {
    logs.insert(
      0,
      "🚧 Road blocked! AI recalculating route...",
    );

    Future.delayed(
      const Duration(seconds: 2),
          () {
        logs.insert(
          0,
          "✅ New safe route generated",
        );

        setState(() {});
      },
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0A0E1A),

      appBar: AppBar(
        backgroundColor: const Color(0xff0D1220),
        title: const Text(
          "🚨 RESCUE ROUTE AI",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          // ================= BUTTONS =================

          Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (simRunning) {
                      stopSimulation();
                    } else {
                      startSimulation();
                    }
                  },
                  child: Text(
                    simRunning
                        ? "Stop Simulation"
                        : "Start Simulation",
                  ),
                ),

                ElevatedButton(
                  onPressed: blockRoad,
                  child: const Text("Block Road"),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showHazards = !showHazards;
                    });
                  },
                  child: Text(
                    showHazards
                        ? "Hide Hazards"
                        : "Show Hazards",
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      mode = mode == "Rescue"
                          ? "Evacuation"
                          : "Rescue";
                    });
                  },
                  child: Text("$mode Mode"),
                ),
              ],
            ),
          ),

          // ================= MAP =================

          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: cityCenter,
                initialZoom: 13,
              ),

              children: [
                TileLayer(
                  urlTemplate:
                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),

                // ================= ROUTES =================

                PolylineLayer(
                  polylines: routes.map((route) {
                    return Polyline(
                      points: List<LatLng>.from(
                        route["points"],
                      ),
                      strokeWidth:
                      activeRoute == route["id"]
                          ? 6
                          : 3,
                      color: route["color"],
                    );
                  }).toList(),
                ),

                // ================= HAZARDS =================

                if (showHazards)
                  CircleLayer(
                    circles: hazards.map((h) {
                      return CircleMarker(
                        point: h["pos"],
                        radius:
                        h["radius"] / 20,
                        color: h["color"]
                            .withOpacity(0.3),
                        borderColor: h["color"],
                        borderStrokeWidth: 2,
                      );
                    }).toList(),
                  ),

                // ================= DISTRESS =================

                CircleLayer(
                  circles:
                  distressLocations.map((d) {
                    return CircleMarker(
                      point: d["pos"],
                      radius: 18,
                      color: Colors.red
                          .withOpacity(0.7),
                      borderColor: Colors.red,
                      borderStrokeWidth: 2,
                    );
                  }).toList(),
                ),

                // ================= TEAMS =================

                MarkerLayer(
                  markers: teams.map((team) {
                    return Marker(
                      point: team["pos"],

                      width: 50,
                      height: 50,

                      child: Column(
                        children: [
                          const Icon(
                            Icons.local_hospital,
                            color:
                            Colors.greenAccent,
                            size: 32,
                          ),

                          Text(
                            team["name"],
                            style:
                            const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // ================= STATS =================

          Container(
            color: const Color(0xff0D1220),
            padding: const EdgeInsets.all(12),

            child: Column(
              children: [
                statRow(
                  "Distress Calls",
                  distressLocations.length
                      .toString(),
                  Colors.redAccent,
                ),

                statRow(
                  "Teams Active",
                  teams.length.toString(),
                  Colors.greenAccent,
                ),

                statRow(
                  "Hazard Zones",
                  hazards.length.toString(),
                  Colors.orangeAccent,
                ),

                statRow(
                  "People Rescued",
                  rescued.toString(),
                  Colors.cyanAccent,
                ),
              ],
            ),
          ),

          // ================= LOGS =================

          Expanded(
            child: Container(
              color: const Color(0xff111827),

              child: ListView.builder(
                itemCount: logs.length,

                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      logs[index],
                      style: TextStyle(
                        color: index == 0
                            ? Colors.greenAccent
                            : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS ROW =================

  Widget statRow(
      String label,
      String value,
      Color color,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}