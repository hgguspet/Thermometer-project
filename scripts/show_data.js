
//define charts
let tempChart;
let humChart;

let data = {
  temp: [],
  hum: [],
  date: [],
};

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

function drawTempGraph() {
  if (!tempChart) {  
    tempChart = new Chart("tempChart", {  
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
  } else {
    tempChart.data.labels = data.date;
    tempChart.data.datasets[0].data = data.temp;
    tempChart.update();
  }
}

function drawHumGraph() {
  if (!humChart) {  
    humChart = new Chart("humChart", {        
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
  } else {
    humChart.data.labels = data.date;
    humChart.data.datasets[0].data = data.hum;
    humChart.update();
  }
}


function update() {
  fetchData();
  drawTempGraph();
  drawHumGraph();
}

setInterval(update, 1500);
