import React, { useState, useEffect } from 'react';
import axios from 'axios';

const DataDisplay = () => {
  const [data, setData] = useState([]);

  useEffect(() => {
    // Fetch data from the backend
    axios.get('http://localhost:5000/data')
      .then((response) => {
        setData(response.data);
      })
      .catch((error) => {
        console.error('Error fetching data:', error);
      });
  }, []);

  return (
    <div>
      <h1>Data from MySQL</h1>
      <ul>
        {data.map((item) => (
          <li key={item.id}>
            Temperature: {item.temperature}, Humidity: {item.humidity}, Date: {item.created_at}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default DataDisplay;

