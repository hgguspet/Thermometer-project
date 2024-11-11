
// define charts
let tempChart;
let humChart;


// define data object
let data = {
  temp: [],
  hum: [],
  date: [],
};

// object to show which table the graphs are currently showing data from
let readFilePaths = {
  // paths to update functions
  bufferReadMode: '/scripts/read_data.php',
  hourlyAvgReadMode : '/scripts/read_hourly_data.php',
}
let currentReadFilePath = readFilePaths.hourlyAvgReadMode;


// dropdown buttons to swap read mode
function setBufferRead() {
  currentReadFilePath = readFilePaths.bufferReadMode;
  update();
}
function setDailyAvgRead() {
  currentReadFilePath = readFilePaths.hourlyAvgReadMode;
  update();
}




/**
 * @brief Fetches data from the server and stores it in the data object.
 * 
 * The function retrieves JSON data from the server at the specified path. It maps
 * the response data to separate arrays for `date`, `temp`, and `hum` within the `data` object.
 * If `date_of_creation` is not available in an entry, it attempts to use `date` instead.
 */
function fetchData() {
  // Initialize data object if not already defined
  if (typeof data === 'undefined') {
    data = { date: [], temp: [], hum: [] };
  }

  fetch(currentReadFilePath)
    .then(response => {
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      return response.json();
    })
    .then(fetchedData => {
      console.log("Fetched data:", fetchedData); // Debug log to check data structure

      // Ensure the data is in the expected format
      if (Array.isArray(fetchedData)) {
        data.date = fetchedData.map(entry => {
          // Check if date_of_creation or reading_time exist and format them accordingly
          let datePart = entry.date_of_creation || entry.reading_time;
          if (datePart) {
            // If date is provided without time, append "00:00:00"
            return datePart.includes(" ") ? datePart : `${datePart} 00:00:00`;
          } else {
            return "No date available";
          }
        });

        data.temp = fetchedData.map(entry => parseFloat(entry.temp || entry.avg_temp || 0));
        data.hum = fetchedData.map(entry => parseFloat(entry.hum || entry.avg_hum || 0));
      } else {
        console.error("Fetched data is not in the expected array format");
      }
    })
    .catch(error => console.error("Error fetching data:", error));
}



/**
 * @brief function to draw / update the temp line graph
 * @param data data object fetched from the mysql database using the fetchData() function
 */
function drawTempGraph(data) {
  // check if graph already exists
  if (!tempChart) {  
    tempChart = new Chart("tempChart", {
      // graph config
      type: "line",
      data: {
        labels: data.date,  
        datasets: [{
          label: "Temperature",
          fill: false,
          tension: 0,
          backgroundColor: "rgba(0, 0, 255, 1)",  
          borderColor: "rgba(0, 0, 255, 1)",  
          data: data.temp  
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            display: true
          }
        },
        scales: {
          x: {
            type: 'category',
            title: {
              display: true,
               text: 'Timestamp',
            },
            reverse: false,
          },
          y: {
            min: 0,
            max: 35,
            title: {
              display: true,
              text: 'Temperature'
            }
          }
        }
      }
    });
    // if the object exists, update it
  } else {
    tempChart.data.labels = data.date;
    tempChart.data.datasets[0].data = data.temp;
    tempChart.update();
  }
}


/**
 * @brief function to draw / update the temp line graph
 * @param data data object fetched from the mysql database using the fetchData() function
 */
function drawHumGraph(data) {
  if (!humChart) {  
    humChart = new Chart("humChart", {
      // graph config
      type: "line",
      data: {
        labels: data.date,
        datasets: [{
          label: "Humitity",
          fill: false,
          tension: 0,
          backgroundColor: "rgba(0, 255, 0, 1)",
          borderColor: "rgba(0, 255, 0, 1)",
          data: data.hum  
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            display: true
          }
        },
        scales: {
          x: {
            type: 'category',
            title: {
              display: true,
              text: 'Timestamp',
            },
            reverse: false,
          },
          y: {
            min: 0,
            max: 100,
            title: {
              display: true,
              text: 'Humitity'
            }
          }
        }
      }
    });
    //if the object exists update it
  } else {
    humChart.data.labels = data.date;
    humChart.data.datasets[0].data = data.hum;
    humChart.update();
  }
}

/**
 * @brief function to update the graphs shown on the website
 * @requires data object
 */
function update() {
  fetchData();
  drawTempGraph(data);
  drawHumGraph(data);
}

setInterval(update, 1500);
