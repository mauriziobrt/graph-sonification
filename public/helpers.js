// var socket = io.connect('http://localhost/');
// socket.on('connect', function () {
//   socket.send('hi');

//   socket.on('message', function (msg) {
//     // my msg
//   });
// });

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
        const message = {
            address: address,
            args: [node["id"], node["openacces"],node["citations"], degree]  // Send frequency as a number
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
        fetch("./data/rich_output.json")
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
