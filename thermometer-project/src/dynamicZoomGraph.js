import React, { useEffect, useRef } from "react";
import * as d3 from "d3";

const DynamicZoomChart = ({ data }) => {
  const svgRef = useRef();

    useEffect(() => {
      const svg = d3.select(svgRef.current);
      svg.selectAll("*").remove(); // Clear previous render

      const width = 800;
      const height = 400;
      const margin = { top: 20, right: 30, bottom: 30, left: 50 };

      const x = d3
        .scaleTime()
        .domain(d3.extent(data, (d) => new Date(d.timestamp)))
        .range([margin.left, width - margin.right]);

      const y = d3
        .scaleLinear()
        .domain([0, d3.max(data, (d) => Math.max(d.temperature, d.humidity))])
        .nice()
        .range([height - margin.bottom, margin.top]);

      const xAxis = (g) =>
        g.attr("transform", `translate(0,${height - margin.bottom})`).call(
          d3.axisBottom(x).ticks(width / 80).tickSizeOuter(0)
        );

      const yAxis = (g) =>
        g.attr("transform", `translate(${margin.left},0)`).call(
          d3.axisLeft(y).ticks(10)
        );

      const temperatureLine = d3
        .line()
        .x((d) => x(new Date(d.timestamp)))
        .y((d) => y(d.temperature));

      const humidityLine = d3
        .line()
        .x((d) => x(new Date(d.timestamp)))
        .y((d) => y(d.humidity));

      const zoom = d3
        .zoom()
        .scaleExtent([1, 10])
        .translateExtent([
          [margin.left, margin.top],
          [width - margin.right, height - margin.bottom],
        ])
        .on("zoom", zoomed);

      function zoomed(event) {
        const transform = event.transform;
        const newX = transform.rescaleX(x);
        svg.select(".x-axis").call(d3.axisBottom(newX));
        svg.select(".temperature-line").attr("d", temperatureLine.x((d) => newX(new Date(d.timestamp))));
        svg.select(".humidity-line").attr("d", humidityLine.x((d) => newX(new Date(d.timestamp))));
      }

      // Add clipping path
      svg
        .append("defs")
        .append("clipPath")
        .attr("id", "clip")
        .append("rect")
        .attr("x", margin.left)
        .attr("y", margin.top)
        .attr("width", width - margin.left - margin.right)
        .attr("height", height - margin.top - margin.bottom);

      svg
        .attr("viewBox", [0, 0, width, height])
        .style("overflow", "hidden")
        .style("border", "1px solid black")
        .call(zoom);

      svg.append("g").attr("class", "x-axis").call(xAxis);
      svg.append("g").attr("class", "y-axis").call(yAxis);

      // Apply clipping to the line paths
      svg
        .append("path")
        .datum(data)
        .attr("class", "temperature-line")
        .attr("fill", "none")
        .attr("stroke", "red")
        .attr("stroke-width", 1.5)
        .attr("clip-path", "url(#clip)") // Use the clipping path
        .attr("d", temperatureLine);

      svg
        .append("path")
        .datum(data)
        .attr("class", "humidity-line")
        .attr("fill", "none")
        .attr("stroke", "blue")
        .attr("stroke-width", 1.5)
        .attr("clip-path", "url(#clip)") // Use the clipping path
        .attr("d", humidityLine);
    }, [data]);
    return <svg ref={svgRef}></svg> 
};
export default DynamicZoomChart;

