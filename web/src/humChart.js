import React, { useEffect } from "react";
import * as d3 from "d3";

const HumD3Chart = ({ data }) => {
    useEffect(() => {
        if (!data || data.length === 0 || !data[0]?.created_at || !data[0]?.humidity) {
            console.warn("Invalid or missing data for chart.");
            return;
        }

        // Clear existing SVG to prevent duplicates
        d3.select("#hum-chart-container").selectAll("*").remove();

        // Chart dimensions
        const width = 500;
        const height = 500;
        const innerRadius = 100;
        const outerRadius = 200;

        // Create SVG
        const svg = d3
            .select("#hum-chart-container")
            .append("svg")
            .attr("width", width)
            .attr("height", height)
            .append("g")
            .attr("transform", `translate(${width / 2}, ${height / 2})`);

        // Add a text element in the center for displaying selected values
        const centerText = svg
            .append("text")
            .attr("text-anchor", "middle")
            .attr("dy", "0.35em") // Vertical alignment
            .style("font-size", "16px")
            .style("font-weight", "bold")
            .style("fill", "#333")
            .text("Select a slice");

        // Parse date and format data
        const parsedData = data.map(d => ({
            ...d,
            date: new Date(d.created_at),
        }));

        // Scales
        const angleScale = d3
            .scaleBand()
            .domain(parsedData.map(d => d.date))
            .range([0, 2 * Math.PI])
            .padding(0.2);

        const humidityScale = d3
            .scaleLinear()
            .domain([0, d3.max(parsedData, d => d.humidity)])
            .range([innerRadius, outerRadius]);

        // Draw humidity bars
        const bars = svg
            .selectAll(".humidity-bar")
            .data(parsedData)
            .enter()
            .append("path")
            .attr("class", "humidity-bar")
            .attr(
                "d",
                d3
                    .arc()
                    .innerRadius(innerRadius)
                    .outerRadius(d => humidityScale(d.humidity))
                    .startAngle(d => angleScale(d.date))
                    .endAngle(d => angleScale(d.date) + angleScale.bandwidth())
                    .padAngle(0.01)
                    .padRadius(innerRadius)
            )
            .attr("fill", "#FFD700") // Yellow color for slices
            .attr("opacity", 1) // Default opacity
            .on("mouseover", function (event, d) {
                // Highlight the hovered slice by increasing its radius and dulling others
                bars.transition()
                    .duration(200)
                    .attr("opacity", 0.5); // Dull all slices

                d3.select(this)
                    .transition()
                    .duration(200)
                    .attr(
                        "d",
                        d3
                            .arc()
                            .innerRadius(innerRadius)
                            .outerRadius(outerRadius + 20) // Zoom effect
                            .startAngle(angleScale(d.date))
                            .endAngle(angleScale(d.date) + angleScale.bandwidth())
                            .padAngle(0.01)
                            .padRadius(innerRadius)
                    )
                    .attr("opacity", 1); // Highlight the hovered slice

                // Update center text
                centerText.text(`Humidity: ${d.humidity}%`);
            })
            .on("mouseout", function () {
                // Reset all slices to original appearance
                bars.transition()
                    .duration(200)
                    .attr("opacity", 1)
                    .attr(
                        "d",
                        d3
                            .arc()
                            .innerRadius(innerRadius)
                            .outerRadius(d => humidityScale(d.humidity))
                            .startAngle(d => angleScale(d.date))
                            .endAngle(d => angleScale(d.date) + angleScale.bandwidth())
                            .padAngle(0.01)
                            .padRadius(innerRadius)
                    );

                // Reset center text
                centerText.text("Select a slice");
            });

        // Add labels (rounded time)
        svg.selectAll("text.label")
            .data(parsedData)
            .enter()
            .append("text")
            .attr("x", d => {
                const angle = angleScale(d.date) + angleScale.bandwidth() / 2;
                return Math.cos(angle) * (outerRadius + 20);
            })
            .attr("y", d => {
                const angle = angleScale(d.date) + angleScale.bandwidth() / 2;
                return Math.sin(angle) * (outerRadius + 20);
            })
            .attr("text-anchor", "middle")
            .text(d => {
                const roundedDate = new Date(d.date);
                roundedDate.setSeconds(0, 0); // Round to the nearest minute
                return roundedDate.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
            })
            .attr("font-size", "10px");
    }, [data]);

    return <div id="hum-chart-container"></div>;
};

export default HumD3Chart;

