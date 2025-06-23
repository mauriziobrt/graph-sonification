import * as d3 from "https://cdn.jsdelivr.net/npm/d3@7/+esm";
import yaml from 'https://cdn.skypack.dev/yaml';

//========================================================
// GLOBAL VARIABLES
//========================================================

let graph;
let degree = {};

let dataTextSpec = "Bibliographic Coupling"; //e.g. Co-citations, Bibliographic Coupling
let dataText = document.getElementById("mySpec");
dataText.innerText = dataTextSpec;
let displayFeatures = false;

//========================================================

async function load_yml(file) {   
    const response = await fetch(file);
    const content = await response.text();
    const yml_cnt = yaml.parse(content)
    // const data_spec = yml_cnt["data-spec"]
    onWasd = yml_cnt["interactions"]["wasd"]
    onTransition = yml_cnt["interactions"]["transition"]
    onSpace = yml_cnt["interactions"]["space"]
    hoverOn = yml_cnt["interactions"]["hover"]
    dataTextSpec = yml_cnt["display-text"]["data-spec"]
    dataText.innerText = dataTextSpec;
    // console.log(yml_cnt["interactions"]["wasd"])
    
    const tmp_text = document.getElementById("textControls");
    if (yml_cnt["display-text"]["display-features"]) {
        tmp_text.style = "z-index: 1";
    } else {
        tmp_text.style = "z-index: 0";
    }
    // return yml_cnt["display-text"]
    // initializeEventListeners();
}

//=================================================================================
//Main Body
//=================================================================================

//========================================================
// LIL GUI
//========================================================

function selectFile() {
  return new Promise((resolve, reject) => {
    // Create a file input element
    const fileInput = document.createElement('input');
    fileInput.type = 'file';
    fileInput.style.display = 'none';
    document.body.appendChild(fileInput);
    
    // Set up event listener for when a file is selected
    fileInput.addEventListener('change', (event) => {
      if (fileInput.files && fileInput.files.length > 0) {
        const fileName = fileInput.files[0].name;
        console.log(`Selected file: ${fileName}`);
        
        // Clean up the file input element
        document.body.removeChild(fileInput);
        
        // Return the file name
        resolve(fileName);
      } else {
        // Clean up if no file was selected
        document.body.removeChild(fileInput);
        reject(new Error('No file selected'));
      }
    });
    
    // Trigger the file selection dialog
    fileInput.click();
  });
}

var GUI = lil.GUI;
const gui = new GUI();
gui.close()
var obj = { 
    // size: 'Medium', 
    hoverOn: false,
    file: "select file",
    loadFile: function() {obj.file = selectFile().fileName},
    textDisplay: true,
    textHelp: true
    // oscPort: 57120,
    // reloadGraph: function() {updateGraphData(obj.file)}
}

var filedata = {"1-hover": ["./data/1-hover.json", "./data/1-config.yml"],
    "2-transition": ["./data/2-transition.json", "./data/2-config.yml"],
    "3-bubbles": ["./data/3-bubbles.json", "./data/3-config.yml"],
    "4-bib-coupling": ["./data/4-bib-coupling.json", "./data/4-config.yml"],
    "5-cit-coupling": ["./data/5-co-cit-coupling.json", "./data/5-config.yml"],
    // "7-test-db": ["./data/network_graph.json", "./data/6-config.yml"]
}

gui.add(obj, "hoverOn");
gui.add(obj, "file", ["1-hover", "2-transition","3-bubbles","4-bib-coupling", "5-cit-coupling"])
gui.add(obj, "textDisplay");
gui.add(obj, "textHelp");

gui.onChange( event => {
    // console.log(event.property)-
    if (event.property  == "hoverOn") {
        hoverOn = event.value;
        console.log('State hover: ', hoverOn);
    }
    if (event.property  == "textDisplay") {
        obj.textDisplay = event.value;
        const tmp_text = document.getElementById("displayText");
        if (obj.textDisplay) {
            tmp_text.style = "z-index: 1";
        } else {
            tmp_text.style = "z-index: 0";
        }
        console.log('State display: ', obj.textDisplay);
    }
    
    if (event.property  == "textHelp") {
        obj.textHelp = event.value;
        const tmp_text = document.getElementById("textControls");
        if (obj.textHelp) {
            tmp_text.style = "z-index: 1";
        } else {
            tmp_text.style = "z-index: 0";
        }
        console.log('State display: ', obj.textHelp);
    }
    // if (event.property == "oscPort") {
    //     console.log(oscClient);
    // }
    if (event.property == "file") {
        const tmpfile = filedata[obj.file]
        updateGraphData(tmpfile[0])
        const tmpdata = load_yml(tmpfile[1])
        // console.log("TMPDATA", tmpdata)
    }
} );

//========================================================
// EVENT LISTENERS
//========================================================

// Initialize event listeners once when the page loads
function initializeEventListeners() {
    // if (onTransition) {
        // Track shift key state
        document.addEventListener('keydown', (event) => {
            if (event.key === 'Shift') {
                shiftKeyPressed = true;
                console.log("shiftKeyPressed");
                
                const element = document.getElementById("miaomiao");
                if (element) {
                    element.innerText = "shift";
                }
            }
        });

        document.addEventListener('keyup', (event) => {
            if (event.key === 'Shift') {
                shiftKeyPressed = false;
                const element = document.getElementById("miaomiao");
                if (element) {
                    element.innerText = "";
                }
                console.log("shiftKeyNotPressed");
                
                // Only clear selection when shift key is released if no animation is running
                // if (!animationInProgress && graph) {
                //     selectedNodes = [];
                //     updateNodeColors(graph);
                // }
            }
        });
    // }
    //================================================================================================
    // WASD - Interaction
    //================================================================================================

    // Set up key event listeners for WASD navigation
    // if (onWasd) {
    document.addEventListener('keydown', (event) => {
        if (!selectedNode) return;
        let direction;
        switch(event.key.toLowerCase()) {
            case 'w':
            direction = 'up';
            break;
            case 's':
            direction = 'down';
            break;
            case 'a':
            direction = 'left';
            break;
            case 'd':
            direction = 'right';
            break;
            default:
            return; // Not a WASD key
        }
        
            const nextNode = findClosestNodeInDirection(selectedNode.id, direction, graph);
            //nextNode si rompe quindi l'errore è lì dentro
            if (nextNode) {
                // Select the new node WITHOUT centering the view
                // stopFaust();
                selectNode(nextNode, true, graph);
                // console.log(nextNode)
                document.getElementById("content").innerText = nextNode["description"];
                // playFaust(220, degree[nextNode.id], "additiveplus", additivePlusNode, audioContext);
                sendOSCMessage(nextNode, "/wasd", degree[nextNode.id])
                // console.log(degree)
            }   
        });
    // }
    //================================================================================================
    // Track space bar state
    //================================================================================================
    // if (onSpace) {
        document.addEventListener('keydown', (event) => {
            if (event.key === ' ') {
                spaceKeyPressed = true;
                document.getElementById("miaomiao").innerText = "space";
                console.log("spaceKeyPressed");
            }
        });

        document.addEventListener('keyup', (event) => {
            if (event.key === ' ') {
                spaceKeyPressed = false;
                document.getElementById("miaomiao").innerText = "";
                console.log("spaceKeyNotPressed");
            }
        });
    // }
}

// Call this once when your page loads
initializeEventListeners();

function main(fileName) {
    fetchExternalData(fileName || obj.file).then(
        (data) => {
            data = data[0];

            // Calculate node degrees
            data.links.forEach(link => {
                // console.log(link.source, link.target, link.weight);
                degree[link.source] = (degree[link.source] || 0) + 1;
                degree[link.target] = (degree[link.target] || 0) + 1;
            });
            
            const max = data.links.reduce((prev, current) => (prev && prev.weight > current.weight) ? prev : current)
            // console.log(max.weight)
            maxWeight = max.weight;
            // Find where the source is the starting point, get an array of that and then find where the target is the end point, there you have the weight

            const elem = document.getElementById('graph');
            
            // Initialize graph only once
            if (!graph) {
                graph = new ForceGraph(elem);
                // Set up your graph configuration here (one-time setup)
                graph
                    .backgroundColor('#101020')
                    .nodeRelSize(6)
                    .nodeLabel(node => `${node.user}: ${node.description}`)
                    .linkCurvature(0.2)
                    .linkWidth(link => link.weight / 2.0)
                    .linkColor(() => linkStaticColor)
                    .nodeVal(node => degree[node.id] || 1) // Default to 1 if no links
                    .d3Force('charge', d3.forceManyBody().strength(node => -degree[node.id] * 20)) // Repulsion
                    .d3Force('collision', d3.forceCollide(node => degree[node.id] * 2)) // Prevent overlap
                    .linkDirectionalParticles(2)
                    .graphData(data)
                    .autoPauseRedraw(false) // keep redrawing after engine has stopped
                    .onNodeHover(node => {
                        if (!node){
                            return
                        }
                        if (node) {
                            if (hoverOn) {
                                selectNode(node, false, graph);
                                document.getElementById("content").innerText = node["description"];
                                sendOSCMessage(node, "/control", degree[node.id])
                            }
                            }
                    }
                );
            }
            
            //================================================================================================
            //Select function depending on status
            //================================================================================================

            // UPDATE LATER, it should also work if there's already a selectednode
            function setupNodeSelection(graph) {
                graph.onNodeClick((node, event) => {
                    // console.log(node)
                    document.getElementById("content").innerText = node["description"];
                    document.getElementById("openaccess").innerText = node["openacces"];
                    document.getElementById("citations").innerText = node["citations"];
                    document.getElementById("year").innerText = node["year"];
                    document.getElementById("co-citations").innerText = degree[node.id];
                    
                    if (shiftKeyPressed) {
                        shiftSelection(node, graph, degree);
                        clearActiveAnimations();
                    } else {
                        selectNode(node, true, graph);
                        clearActiveAnimations();
                    if (spaceKeyPressed) {highlightNeighborsGradually(node, graph, degree, data)};
                    }
                    
                });
            }
            setupNodeSelection(graph)

            //================================================================================================
            //COLORS
            //================================================================================================

            // Create a color scale using d3-scale
            function createColorScale(graph) {
                // Get all unique user values
                const nodes = graph.graphData().nodes;
                const userValues = [...new Set(nodes.map(node => node.openacces))];
                // Create a color scale with d3
                // const colorScale = d3.scaleSequential([0, 100], d3.interpolateBlues);
                const colorScale = d3.scaleOrdinal()
                .domain(userValues)
                .range(d3.schemePaired); // Use a predefined color scheme
            return colorScale;
            }

            const colorScale = createColorScale(graph)

            graph.nodeColor(node => {
                // Use the same coloring scheme you had initially
                // For example, if you used a color scale based on user property:
                return colorScale(node.openacces);
            });


            // Function to handle background clicks with Force Graph library
            function setupBackgroundClick(graph) {
                // Add event listener to background clicks
                graph.onBackgroundClick(() => {
                // Reset selections
                selectedNodes = [];
                selectedNode = null;
                highlightedPath = [];
                clearActiveAnimations();
                clearTransitionAnimations();
                graph.nodeColor(node => {
                    // Use the same coloring scheme you had initially
                    // For example, if you used a color scale based on user property:
                    return colorScale(node.openacces);
                    });
                // Reset link coloring and width
                graph.linkCurvature(0.2)
                graph.linkWidth(node => node.weight / 2.0)
                });
            }
            setupBackgroundClick(graph)

            graph.graphData({ nodes: [], links: [] }); // Clear old graph data

            // Update graph data (this is what you want for dynamic updates)
            graph.graphData(data);

            if (selectedNode) {
                selectedNode = graph.graphData().nodes.find(n => n.id === selectedNode.id) || graph.graphData().nodes[0] || null;
            } else {
                selectedNode = graph.graphData().nodes[0] || null;
            }
            // Optional: Restart the simulation to re-position nodes
            graph.d3ReheatSimulation();
        }
    ).catch(error => {
        console.error('Error loading graph data:', error);
    });
}

// Function to specifically update graph with new file
function updateGraphData(fileName) {
    main(fileName);
}

load_yml("./data/5-config.yml")
main("./data/5-co-cit-coupling.json")
// main("./data/1-hover.json")
// main("./data/network_graph.json")
// main("./data/fake_son.json")
// main("./data/fab_son.json")