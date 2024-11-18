import React, { useRef, useEffect } from 'react';
import * as d3 from 'd3';

const LineGraph = ({ data }) => {
    const svgRef = useRef();

    useEffect(() => {
        const width = 500;
        const height = 300;
        const margin = { top: 20, right: 20, bottom: 40, left: 50 };

        // 1. Select SVG and set dimensions
        const svg = d3.select(svgRef.current)
            .attr('width', width)
            .attr('height', height)
            .style('background', '#f0f0f0')
            .style('overflow', 'visible')
            .style('margin-top', '10px');

        // 2. Create Scales
        const xScale = d3
            .scaleLinear()
            .domain([0, data.length - 1]) // Data index as domain
            .range([margin.left, width - margin.right]); // Pixels range

        const yScale = d3
            .scaleLinear()
            .domain([0, d3.max(data)]) // Data values as domain
            .range([height - margin.bottom, margin.top]); // Pixels range

        // 3. Line Generator
        const line = d3
            .line()
            .x((d, i) => xScale(i)) // Maps data index to x-axis
            .y((d) => yScale(d)) // Maps data value to y-axis
            .curve(d3.curveMonotoneX); // Optional: Smoothens the line

        // 4. Append X and Y Axes
        const xAxis = d3.axisBottom(xScale).ticks(data.length);
        const yAxis = d3.axisLeft(yScale).ticks(5);

        svg.selectAll('.x-axis').remove(); // Clear previous axes
        svg.selectAll('.y-axis').remove();

        svg.append('g')
            .attr('class', 'x-axis')
            .attr('transform', `translate(0, ${height - margin.bottom})`)
            .call(xAxis);

        svg.append('g')
            .attr('class', 'y-axis')
            .attr('transform', `translate(${margin.left}, 0)`)
            .call(yAxis);

        // 5. Draw the Line
        svg.selectAll('.line').remove(); // Clear previous lines
        svg.append('path')
            .datum(data) // Bind data
            .attr('fill', 'none')
            .attr('stroke', 'blue')
            .attr('stroke-width', 2)
            .attr('d', line); // Use the line generator

    }, [data]); // Re-render whenever `data` changes

    return <svg ref={svgRef}></svg>;
};

export default LineGraph;

