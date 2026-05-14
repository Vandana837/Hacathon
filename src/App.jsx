import { useState, useEffect } from "react";
import {
  MapContainer,
  TileLayer,
  Polyline,
  Circle,
  Marker,
  Popup,
} from "react-leaflet";

import "leaflet/dist/leaflet.css";
import L from "leaflet";

// ================= FIX MARKER =================

delete L.Icon.Default.prototype._getIconUrl;

L.Icon.Default.mergeOptions({
  iconRetinaUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png",

  iconUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png",

  shadowUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png",
});

// ================= AMBULANCE ICON =================

const ambulanceIcon = new L.Icon({
  iconUrl:
    "https://cdn-icons-png.flaticon.com/512/2967/2967350.png",

  iconSize: [35, 35],
});

// ================= CENTER =================

const CITY_CENTER = [13.0827, 80.2707];

// ================= TEAMS =================

const INITIAL_TEAMS = [
  {
    id: 1,
    name: "Alpha Team",
    start: [13.0827, 80.2707],
  },
];

// ================= ROUTES =================

const ROUTES = {
  fastest: [
    [13.0827, 80.2707],
    [13.078, 80.265],
    [13.07, 80.255],
  ],

  safest: [
    [13.0827, 80.2707],
    [13.095, 80.285],
    [13.07, 80.255],
  ],

  optimized: [
    [13.0827, 80.2707],
    [13.088, 80.272],
    [13.07, 80.255],
  ],
};

// ================= APP =================

export default function App() {
  const [teams, setTeams] = useState(INITIAL_TEAMS);

  const [hazards, setHazards] = useState([
    {
      id: 1,
      pos: [13.078, 80.265],
      radius: 700,
      label: "Flood Zone",
    },
  ]);

  const [logs, setLogs] = useState([
    "🚨 Rescue AI System Initialized",
  ]);

  const [simRunning, setSimRunning] =
    useState(false);

  const [showHazards, setShowHazards] =
    useState(true);

  const [roadBlocked, setRoadBlocked] =
    useState(false);

  const [activeRoute, setActiveRoute] =
    useState("optimized");

  const [rescued, setRescued] =
    useState(0);

  const [mode, setMode] =
    useState("Rescue");

  // ================= SIMULATION =================

  useEffect(() => {
    if (!simRunning) return;

    const interval = setInterval(() => {
      // MOVE TEAM

      setTeams((prev) =>
        prev.map((team) => ({
          ...team,

          start: [
            team.start[0] +
              (Math.random() - 0.5) * 0.002,

            team.start[1] +
              (Math.random() - 0.5) * 0.002,
          ],
        }))
      );

      // EXPAND HAZARDS

      setHazards((prev) =>
        prev.map((h) => ({
          ...h,
          radius: h.radius + 40,
        }))
      );

      // RESCUED PEOPLE

      setRescued((prev) =>
        Math.min(prev + 2, 100)
      );

      // LOGS

      setLogs((prev) => [
        "⚠ Hazard zone expanded",
        ...prev.slice(0, 8),
      ]);
    }, 4000);

    return () => clearInterval(interval);
  }, [simRunning]);

  // ================= BLOCK ROAD =================

  const blockRoad = () => {
    setRoadBlocked(true);

    setLogs((prev) => [
      "🚧 Main route blocked!",
      ...prev.slice(0, 8),
    ]);

    setTimeout(() => {
      setLogs((prev) => [
        "🤖 AI recalculating safer route...",
        ...prev.slice(0, 8),
      ]);
    }, 1000);

    setTimeout(() => {
      setActiveRoute("safest");

      setLogs((prev) => [
        "✅ Safer route selected successfully",
        ...prev.slice(0, 8),
      ]);
    }, 2500);
  };

  // ================= ROUTE DETAILS =================

  const routeDetails = {
    fastest: {
      color: roadBlocked
        ? "#FF4444"
        : "#00CFFF",

      time: "5 min",
      safety: roadBlocked
        ? "45%"
        : "72%",

      distance: "2.8 km",
    },

    optimized: {
      color: "#00FF88",
      time: "8 min",
      safety: roadBlocked
        ? "60%"
        : "94%",

      distance: "3.1 km",
    },

    safest: {
      color: "#FFD700",
      time: "11 min",
      safety: "98%",
      distance: "4.2 km",
    },
  };

  return (
    <div
      style={{
        height: "100vh",
        display: "flex",
        flexDirection: "column",
        background: "#0A0E1A",
        color: "#FFF",
        fontFamily: "monospace",
      }}
    >
      {/* ================= HEADER ================= */}

      <div
        style={{
          padding: "12px 20px",
          background: "#0D1220",
          borderBottom: "2px solid #FF4444",

          display: "flex",
          justifyContent: "space-between",

          flexWrap: "wrap",
        }}
      >
        <div>
          <span
            style={{
              color: "#FF4444",
              fontWeight: "bold",
              fontSize: "20px",
            }}
          >
            🚨 RESCUE ROUTE AI
          </span>

          <span
            style={{
              marginLeft: "12px",
              color: simRunning
                ? "#00FF88"
                : "#888",
            }}
          >
            {simRunning
              ? "● LIVE"
              : "○ OFFLINE"}
          </span>
        </div>

        <div
          style={{
            display: "flex",
            gap: "10px",
          }}
        >
          <button
            onClick={() =>
              setSimRunning(!simRunning)
            }
            style={buttonStyle("#00FF88")}
          >
            {simRunning
              ? "⏹ Stop"
              : "▶ Start"}
          </button>

          <button
            onClick={blockRoad}
            style={buttonStyle("#FF8800")}
          >
            🚧 Block Road
          </button>

          <button
            onClick={() =>
              setShowHazards(!showHazards)
            }
            style={buttonStyle("#FF44FF")}
          >
            {showHazards
              ? "Hide Hazards"
              : "Show Hazards"}
          </button>

          <button
            onClick={() =>
              setMode(
                mode === "Rescue"
                  ? "Evacuation"
                  : "Rescue"
              )
            }
            style={buttonStyle("#00CFFF")}
          >
            {mode} Mode
          </button>
        </div>
      </div>

      {/* ================= MAIN ================= */}

      <div
        style={{
          display: "flex",
          flex: 1,
        }}
      >
        {/* ================= MAP ================= */}

        <div style={{ flex: 1 }}>
          <MapContainer
            center={CITY_CENTER}
            zoom={13}
            style={{
              height: "100%",
              width: "100%",
            }}
          >
            <TileLayer
              url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
            />

            {/* HAZARDS */}

            {showHazards &&
              hazards.map((hazard) => (
                <Circle
                  key={hazard.id}
                  center={hazard.pos}
                  radius={hazard.radius}
                  pathOptions={{
                    color: "#FF4444",
                    fillColor: "#FF4444",
                    fillOpacity: 0.4,
                  }}
                >
                  <Popup>
                    ⚠ {hazard.label}
                  </Popup>
                </Circle>
              ))}

            {/* ROUTES */}

            {Object.entries(ROUTES).map(
              ([key, path]) => (
                <Polyline
                  key={key}
                  positions={path}
                  pathOptions={{
                    color:
                      routeDetails[key]
                        .color,

                    weight:
                      activeRoute === key
                        ? 7
                        : 3,

                    opacity:
                      activeRoute === key
                        ? 1
                        : 0.4,
                  }}
                />
              )
            )}

            {/* TEAMS */}

            {teams.map((team) => (
              <Marker
                key={team.id}
                position={team.start}
                icon={ambulanceIcon}
              >
                <Popup>
                  🚑 {team.name}
                  <br />
                  Status: Active
                  <br />
                  Mode: {mode}
                </Popup>
              </Marker>
            ))}
          </MapContainer>
        </div>

        {/* ================= SIDEBAR ================= */}

        <div
          style={{
            width: "300px",
            background: "#0D1220",
            borderLeft: "1px solid #222",
            overflow: "auto",
          }}
        >
          {/* ROUTES */}

          <div
            style={{
              padding: "15px",
              borderBottom: "1px solid #222",
            }}
          >
            <div
              style={{
                color: "#666",
                marginBottom: "12px",
              }}
            >
              AI ROUTES
            </div>

            {Object.entries(routeDetails).map(
              ([key, data]) => (
                <div
                  key={key}
                  onClick={() =>
                    setActiveRoute(key)
                  }
                  style={{
                    padding: "10px",
                    marginBottom: "10px",

                    border:
                      activeRoute === key
                        ? `1px solid ${data.color}`
                        : "1px solid #222",

                    borderRadius: "6px",

                    cursor: "pointer",

                    background:
                      activeRoute === key
                        ? data.color + "20"
                        : "transparent",
                  }}
                >
                  <div
                    style={{
                      color: data.color,
                      fontWeight: "bold",
                    }}
                  >
                    {key.toUpperCase()}
                  </div>

                  <div>
                    ⏱ {data.time}
                  </div>

                  <div>
                    🛡 {data.safety}
                  </div>

                  <div>
                    📍 {data.distance}
                  </div>
                </div>
              )
            )}
          </div>

          {/* ANALYTICS */}

          <div
            style={{
              padding: "15px",
              borderBottom: "1px solid #222",
            }}
          >
            <div
              style={{
                color: "#666",
                marginBottom: "12px",
              }}
            >
              LIVE AI ANALYTICS
            </div>

            <Stat
              label="Teams Active"
              value={teams.length}
              color="#00FF88"
            />

            <Stat
              label="Hazard Zones"
              value={hazards.length}
              color="#FFD700"
            />

            <Stat
              label="People Rescued"
              value={rescued}
              color="#00CFFF"
            />
          </div>

          {/* LOGS */}

          <div style={{ padding: "15px" }}>
            <div
              style={{
                color: "#666",
                marginBottom: "12px",
              }}
            >
              LIVE SYSTEM LOGS
            </div>

            {logs.map((log, i) => (
              <div
                key={i}
                style={{
                  padding: "6px 0",
                  fontSize: "12px",

                  color:
                    i === 0
                      ? "#00FF88"
                      : "#777",
                }}
              >
                {log}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// ================= BUTTON STYLE =================

function buttonStyle(color) {
  return {
    background: color + "22",
    border: `1px solid ${color}`,
    color: color,
    padding: "8px 14px",
    borderRadius: "5px",
    cursor: "pointer",
    fontFamily: "monospace",
  };
}

// ================= STATS =================

function Stat({ label, value, color }) {
  return (
    <div
      style={{
        display: "flex",
        justifyContent: "space-between",
        marginBottom: "8px",
      }}
    >
      <span style={{ color: "#888" }}>
        {label}
      </span>

      <span
        style={{
          color: color,
          fontWeight: "bold",
        }}
      >
        {value}
      </span>
    </div>
  );
}