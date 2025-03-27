# graph-sonification

Interface for the sonification of graphs using OSC. Graphs can be loaded as json inside the ```helpers.js``` file. You can find an example of the json inside ```/data/correct_output.json```.

### Run the following from terminal to initialize: 

1. `npm init -y`
2. `npm install --save express osc-js ws`
3. `node server.js`

# Commands

## Toggle Enabled:
    
    Hover on node = sonify the node

## OnNode:

    Shif+Click = Find shortest path between nodes and sonify it
    Spacebar+Click = Sonify number of neighbors temporally

## OnBackground:

    Click = Reset view