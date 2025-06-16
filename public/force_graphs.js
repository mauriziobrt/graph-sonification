import * as d3 from "https://cdn.jsdelivr.net/npm/d3@7/+esm";

//=================================================================================
//Main Body
//=================================================================================

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
var obj = { 
    // size: 'Medium', 
    hoverOn: false,
    file: "./data/co-cit-rich.json",
    loadFile: function() {obj.file = selectFile().fileName},
    oscPort: 57120,
    // reloadGraph: function() {main()}
}

gui.add(obj, "hoverOn");
gui.add(obj, "file", ["./data/co-cit-rich.json", "./data/rich_output.json"])
gui.add( obj, 'oscPort' ); 	// number field

gui.onChange( event => {
    console.log(event.property)
    if (event.property  == "hoverOn") {
        hoverOn = event.value;
        console.log('State hover: ', hoverOn);
    }
    if (event.property == "oscPort") {
        console.log(oscClient);
    }
    if (event.property == "file") {
        main()
    }
} );

let graph;

function main() {
    fetchExternalData(obj.file).then(
        (data) => {
            data = data[0]
            const degree = {};
                data.links.forEach(link => {
                degree[link.source] = (degree[link.source] || 0) + 1;
                degree[link.target] = (degree[link.target] || 0) + 1;
        });
    
        const highlightNodes = new Set();
        const highlightLinks = new Set();
        const elem = document.getElementById('graph');
        if (!graph){
            const graph = new ForceGraph(elem);
        else {graph.graphData = elem}
    //================================================================================================
    // Reload Graph
    //================================================================================================
    // function updateGraph(graph)  {
    //     graph.graphData(elem)
    // }
    // updateGraph(graph)

    (async () => {
            //=================================================================================
            //Graph
            //=================================================================================
            graph
                .backgroundColor('#101020')
                .nodeRelSize(6)
                .nodeLabel(node => `${node.user}: ${node.description}`)
                .linkCurvature(0.2)
                .linkWidth(node => node.weight / 2.0)
                .linkColor(() => linkStaticColor)
                .nodeVal(node => degree[node.id] || 1) // Default to 1 if no links
                .d3Force('charge', d3.forceManyBody().strength(node => -degree[node.id] * 20)) // Repulsion
                .d3Force('collision', d3.forceCollide(node => degree[node.id] * 2)) // Prevent overlap
                .linkDirectionalParticles(1)
                .graphData(data)
                .autoPauseRedraw(false) // keep redrawing after engine has stopped
                .onLinkHover(link => {
                    highlightNodes.clear();
                    highlightLinks.clear();

                    if (link) {
                    highlightLinks.add(link);
                    highlightNodes.add(link.source);
                    highlightNodes.add(link.target);
                    };
                })
                .onNodeHover(node => {
                    
                if (!node){
                    return
                }
                if (node) {
                    if (hoverOn) {
                        document.getElementById("content").innerText = node["description"];
                        sendOSCMessage(node, "/control", degree[node.id])
                    }
                    }
                });
            
            //================================================================================================
            //Select function depending on status
            //================================================================================================

            // UPDATE LATER, it should also work if there's already a selectednode
            function setupNodeSelection(graph) {
                graph.onNodeClick((node, event) => {
                    console.log(node)
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
            graph.nodeColor(node => {
                // Use the same coloring scheme you had initially
                // For example, if you used a color scale based on user property:
                return colorScale(node.openacces);
            });

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

            //================================================================================================
            // WASD - Interaction
            //================================================================================================

            // Set up key event listeners for WASD navigation
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
            const nextNode = findClosestNodeInDirection(selectedNode, direction, graph);

            if (nextNode) {
                // Select the new node WITHOUT centering the view
                stopFaust();
                selectNode(nextNode, false, graph);
                // console.log(nextNode)
                document.getElementById("content").innerText = nextNode["description"];
                // playFaust(220, degree[nextNode.id], "additiveplus", additivePlusNode, audioContext);
                sendOSCMessage(nextNode, "/wasd", degree[nextNode.id])
            }
            });

            //================================================================================================
            // Track shift key state
            //================================================================================================
            document.addEventListener('keydown', (event) => {
                if (event.key === 'Shift') {
                    shiftKeyPressed = true;
                    console.log("shiftKeyPressed");
                    document.getElementById("miaomiao").innerText = "shift";
                }
            });
            
            document.addEventListener('keyup', (event) => {
                if (event.key === 'Shift') {
                    shiftKeyPressed = false;
                    document.getElementById("miaomiao").innerText = "";
                    console.log("shiftKeyNotPressed");
                // Only clear selection when shift key is released if no animation is running
                if (!animationInProgress) {
                    selectedNodes = [];
                    updateNodeColors(graph);
                }
                }
            });


            //================================================================================================
            // Track space bar state
            //================================================================================================
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
            
        })()
});
}
main()