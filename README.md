# graph-sonification

Interface for the sonification of graphs using FaustWasm. Graphs can be loaded as json inside the ```helpers.js``` file. You can find an example of the json inside ```/data/correct_output.json```.

Currently only works with local python server or vscode live server.
To start, run ```python -m http.server``` or click on index.html in vscode (with the live server extension installed) and launch.


# Commands

### Toggle Enabled:
    
    Hover on node = sonify the node

### OnNode:

    Shif+Click = Find shortest path between nodes and sonify it
    Spacebar+Click = Sonify number of neighbors temporally

### OnBackground:

    Click = Reset view