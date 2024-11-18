import React from "react";
import DynamicZoomGraph from "./dynamicZoomGraph.js";

const App = () => {
  // Example data: Array of { timestamp, temperature, humidity }
  const data = [
    { timestamp: "2024-11-18T00:00:00Z", temperature: 22, humidity: 60 },
    { timestamp: "2024-11-18T00:05:00Z", temperature: 23, humidity: 58 },
    { timestamp: "2024-11-18T00:10:00Z", temperature: 24, humidity: 57 },
    // Add more data points as needed
  ];

  return (
    <div>
      <h1>Dynamic Zooming Chart</h1>
      <DynamicZoomGraph data={data} />
    </div>
  );
};

export default App;

