const express = require('express');
const WebSocket = require('ws');
const OSC = require('osc-js');
const http = require('http');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Serve static files
app.use(express.static('public'));

// Create OSC UDP client
const oscClient = new OSC({
  plugin: new OSC.DatagramPlugin({
    send: {
      port: 57121,      // SuperCollider's default OSC port
      host: 'localhost'
    }
  })
});

// wss.on('connection', (ws) => {
//   console.log('Client connected');
  
//   ws.on('message', (message) => {
//     // console.log("message")
//     try {
//       const data = JSON.parse(message);
//       console.log(data);
//       // Convert number strings to actual numbers
//       const args = data.args.map(arg => typeof arg === 'string' && !isNaN(arg) ? Number(arg) : arg);
//       const oscMessage = new OSC.Message(data.address, ...args); // Spread the args array
//       oscClient.send(data);
//       console.log('Sent OSC message:', oscMessage);
//     } catch (error) {
//       console.error('Error processing message:', error);
//     }
//   });
// });

wss.on('connection', (ws) => {
    console.log('Client connected');
    ws.on('message', (message) => {
      try {
        const data = JSON.parse(message);
        
        // Normalize args to an array
        const args = Array.isArray(data.args) 
          ? data.args 
          : [data.args];
   
        // Convert string numbers to actual numbers
        const processedArgs = args.map(arg => 
          typeof arg === 'string' && !isNaN(arg) ? Number(arg) : arg
        );
        
        const oscMessage = new OSC.Message(data.address, ...processedArgs);
        oscClient.send(oscMessage);
        ws.send(oscMessage);
        console.log('Sent OSC message:', oscMessage);
      } catch (error) {
        console.error('Error processing message:', error);
        ws.send(JSON.stringify({ 
          error: 'Failed to process message', 
          details: error.message 
        }));
      }
    });
});

const PORT = 7700;
server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
  oscClient.open();
});