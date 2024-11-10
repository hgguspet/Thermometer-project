
// define charts
let tempChart;
let humChart;

// timeframe drop down object
const timeframe = document.getElementById('analysisTimeframe');

// define data object
let data = {
  temp: [],
  hum: [],
  date: [],
};



timeframe.addEventListener('change', function() {
  const value = timeframe.value;
  console.log(value);

});


/**
 * @brief function to fetch data from the server and store it in the data object 
 */
function fetchData() {
  fetch('/scripts/read_data.php')
    .then(response => response.json())
    .then(fetchedData => {
      data.date = fetchedData.map(entry => entry.date_of_creation);
      data.temp = fetchedData.map(entry => parseFloat(entry.temp));
      data.hum = fetchedData.map(entry => parseFloat(entry.hum));
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
            reverse: true,
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
            reverse: true,
          },
          y: {
            min: 0,
            max: 35,
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
