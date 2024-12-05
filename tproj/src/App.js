import React, { useState, useEffect } from "react";
import axios from "axios";
import TempD3Chart from "./graph.js";
import HumD3Chart from "./humChart.js";
import "./App.css";

const App = () => {
    const [data, setData] = useState([]);

    // Read the port from the environment variable
    const serverPort = process.env.REACT_APP_SERVER_PORT;

    // Validate that the port is defined
    if (!serverPort) {
        throw new Error(
            "Environment variable REACT_APP_SERVER_PORT is not defined. Please set it in your .env file."
        );
    }

    useEffect(() => {
        // Fetch data from the server
        const fetchData = async () => {
            try {
                const response = await axios.get(`http://localhost:${serverPort}/data`);
                setData(response.data);
            } catch (error) {
                console.error("Error fetching data:", error);
            }
        };

        fetchData();
    }, [serverPort]);

    return (
        <div>
            <div className="pageContainer">
                <div className="centerBox">
                    <div className="graphContainer">
                        <div className="textBox">
                            <h1>Temperature</h1>
                        </div>
                        <div className="graphBox">
                            <TempD3Chart data={data} />
                        </div>
                    </div>
                    <div className="graphContainer">
                        <div className="textBox">
                            <h1>Humidity</h1>
                        </div>
                        <div className="graphBox">
                            <HumD3Chart data={data} />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default App;

