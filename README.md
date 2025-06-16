# Force-Layout Graph Sonification

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15197962.svg)](https://doi.org/10.5281/zenodo.15197962)

![](graph-screen.png)

Interface for the sonification of graphs using OSC. Graphs can be loaded as json inside the ```helpers.js``` file. You can find an example of a properly formatted json inside ```/data/correct_output.json```.

## Requirements:
- Supercollider - [Download Link](https://supercollider.github.io/)

## Run the following from terminal to initialize: 

1. `npm init -y`
2. `npm install --save express osc-js ws`
3. `node server.js`
4. open the link displayed after you launch the previous command

## From Supercollider

Evaluate the code by opening the file `graph_communication.scd`, boot the server and press `cmd+enter` on the highlighted portion of code.  

## Modes of interaction

The user can interact with the graph using four different inputs: (1)
Mouse hover on nodes, (2) WASD keyboard navigation on node,
(3) Spacebar + mouse click on a node, and (4) Shift + mouse click
on two nodes. The use of these gestures triggers both a sonic and
a visual event.

### 1. Toggle Enabled:
    
- Hover on node = sonify the node

### 2. WASD navigation:

- Use WASD keys to navigate around nodes

### 3. Click On Node:

- Spacebar+Click = Sonify number of neighbors temporally

### 4. Nearest Path:

- Shif+Click = Find shortest path between nodes and sonify it


### 5. OnBackground:

- Click = Reset view

## To-Do
- [ ] Add menu https://lil-gui.georgealways.com/
- [ ] Cleaner Menu with https://jamiebuilds.github.io/tinykeys/
- [ ] Add loading screen with drag and drop loading of file