// var socket = io.connect('http://localhost/');
// socket.on('connect', function () {
//   socket.send('hi');

//   socket.on('message', function (msg) {
//     // my msg
//   });
// });

// function mapValue(inputVal, options = {}) {
//     // Default parameters
//     const inMin = options.inMin !== undefined ? options.inMin : 0;
//     const inMax = options.inMax !== undefined ? options.inMax : 860;
//     const outMin = options.outMin !== undefined ? options.outMin : 5000;
//     const outMax = options.outMax !== undefined ? options.outMax : 10000;

//     // Optional focus range parameters (for special emphasis on a particular range)
//     const focusRangeEnd = options.focusRangeEnd !== undefined ? options.focusRangeEnd : 20;
//     const focusRangeOutput = options.focusRangeOutput !== undefined ? options.focusRangeOutput : 3000;
//     const focusLogBase = options.focusLogBase !== undefined ? options.focusLogBase : 1.2;
//     const mainLogBase = options.mainLogBase !== undefined ? options.mainLogBase : 4;

//     // Ensure input is within bounds
//     inputVal = Math.max(inMin, Math.min(inMax, inputVal));

//     // For values in the focus range
//     if (inputVal <= focusRangeEnd) {
//         // Map focus range using log scale
//         const normalized = (Math.log(inputVal - inMin + 1) / Math.log(focusLogBase)) / 
//                             (Math.log(focusRangeEnd - inMin + 1) / Math.log(focusLogBase));
//         return Math.round(outMin + normalized * (focusRangeOutput - outMin));
//     } else {
//         // Map remaining range using log scale
//         const normalized = (Math.log(inputVal - focusRangeEnd) / Math.log(mainLogBase)) / 
//                             (Math.log(inMax - focusRangeEnd) / Math.log(mainLogBase));
//         return Math.round(focusRangeOutput + normalized * (outMax - focusRangeOutput));
// }
// }

const mapNumRange = (num, inMin, inMax, outMin, outMax) =>
    ((num - inMin) * (outMax - outMin)) / (inMax - inMin) + outMin;
  
//======================================================================
// Server Part
//======================================================================

let ws;

// const statusDiv = document.getElementById('status');

// function updateStatus(message, isError = false) {
//     statusDiv.textContent = message;
//     statusDiv.style.color = isError ? 'red' : 'black';
// }

function connectWebSocket() {
    ws = new WebSocket('ws://localhost:7700');
    
    ws.onopen = () => {
        console.log('Connected to WebSocket server');
        // updateStatus('Connected to WebSocket server');
    };
    
    ws.onclose = () => {
        console.log('Disconnected from WebSocket server');
        // updateStatus('Disconnected from WebSocket server - Retrying...', true);
        // Try to reconnect in 5 seconds
        setTimeout(connectWebSocket, 5000);
    };
    
    ws.onerror = (error) => {
        console.error('WebSocket error:', error);
        // updateStatus('WebSocket error occurred', true);
    };
}

function sendOSCMessage(node, address, degree) {
    if (ws && ws.readyState === WebSocket.OPEN) {
        const cit = node["citations"];
        // const timeCit = mapValue(cit, {
        //     inMin: 0,
        //     inMax: 836,
        //     outMin: 5000,
        //     outMax: 10000,
        //     focusRangeEnd: 30,
        //     focusRangeOutput: 0.4
        // });
        timeCit = mapNumRange(cit, 0,836,5000,10000);
        console.log("TIME SENT: ", timeCit)
        const message = {
            address: address,
            args: [node["id"], node["openacces"],cit, degree, timeCit, node["year"]]
        };
        document.getElementById("openaccess").innerText = node["openacces"];
        document.getElementById("citations").innerText = cit;
        document.getElementById("co-citations").innerText = degree;
        document.getElementById("year").innerText = node["year"];
        ws.send(JSON.stringify(message));
        console.log('Sent message:', message);
    } else {
        // updateStatus('WebSocket not connected', true);
    }
}
function sendOSCStopMessage(address) {
    if (ws && ws.readyState === WebSocket.OPEN) {
        const message = {
            address: address,
            args: [0, 0 , 0, 0, 0]  // Send frequency as a number
        };
        ws.send(JSON.stringify(message));
        console.log('Sent message:', message);
        // updateStatus(`Sent frequency: ${frequency}Hz`);
    } else {
        // updateStatus('WebSocket not connected', true);
    }
}

// Connect when the page loads
connectWebSocket();

//======================================================================
// Server Part
//======================================================================

function fetchExternalData() {
    return Promise.all([
        fetch("./data/co-cit-rich.json"),
        // fetch("./data/rich_output.json")
    ])
        .then(
            results => Promise.all(
                results.map(result => result.json())
            )
        );
}

// Variables to track state
let selectedNode = null;
let selectedNodes = [];
let shiftKeyPressed = false;
let spaceKeyPressed = false;
let hoverOn = false;
let animationInProgress = false;
let highlightedPath = [];
let animationTimer = null;
let linkStaticColor = 'rgba(104, 100, 100, 0.3)';


