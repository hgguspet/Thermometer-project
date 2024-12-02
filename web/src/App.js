import React, { useState, useEffect } from "react";
import axios from "axios";
import TempD3Chart from "./graph.js";
import HumD3Chart from "./humChart.js";
import "./App.css";

const App = () => {
    const [data, setData] = useState([]);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const response = await axios.get("http://localhost:5000/data");
                setData(response.data);
            } catch (error) {
                console.error("Error fetching data:", error);
            }
        };

        fetchData();
    }, []);

    return (
        <div>
            <div className="pageContainer">
                <div className="centerBox">
                    <div className="graphContainer">
                        <div className="textBox">
                            <h1>Temperature</h1>
                        </div>
                        <div className = "graphBox">
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

