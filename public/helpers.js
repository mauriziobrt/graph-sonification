const mapNumRange = (num, inMin, inMax, outMin, outMax) =>
    ((num - inMin) * (outMax - outMin)) / (inMax - inMin) + outMin;
  
//======================================================================
// Server Part
//======================================================================

let ws;

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
        timeCit = mapNumRange(cit, 0,836,5000,10000);
        // console.log("TIME SENT: ", timeCit)
        if (node["cluster"]) {
            const message = {
                address: address,
                args: [node["id"], node["openacces"],cit, degree, timeCit, node["year"], node["x"], node["y"], node["cluster"]]
            };
            document.getElementById("openaccess").innerText = node["openacces"];
            document.getElementById("citations").innerText = cit;
            document.getElementById("co-citations").innerText = degree;
            document.getElementById("year").innerText = node["year"];
            ws.send(JSON.stringify(message));
        }else
        {
            const message = {
            address: address,
            args: [node["id"], node["openacces"],cit, degree, timeCit, node["year"], node["x"], node["y"], 1]
            };
            document.getElementById("openaccess").innerText = node["openacces"];
            document.getElementById("citations").innerText = cit;
            document.getElementById("co-citations").innerText = degree;
            document.getElementById("year").innerText = node["year"];
            ws.send(JSON.stringify(message));
        }

        // console.log("X: ", node["x"], ". Y: ", node["y"], ". VX: ", node["vx"], ". VY: ", node["vy"])
        // console.log('Sent message:', message);
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

function fetchExternalData(file) {
    return Promise.all([
        fetch(file),
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


