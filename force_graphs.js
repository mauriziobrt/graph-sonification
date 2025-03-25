import * as d3 from "https://cdn.jsdelivr.net/npm/d3@7/+esm";

//=================================================================================
//Main Body
//=================================================================================

fetchExternalData().then(
    (data) => {
    data = data[0]
    const degree = {};
        data.links.forEach(link => {
        degree[link.source] = (degree[link.source] || 0) + 1;
        degree[link.target] = (degree[link.target] || 0) + 1;
    });
    
    
    var checkbox = document.getElementById('mitch');

    checkbox.addEventListener('change', function () {
        if (checkbox.checked) {
        hoverOn = true;
        console.log('Checked');
        } else {
        hoverOn = false;
        console.log('Not checked');
        }
    });


    const highlightNodes = new Set();
    const highlightLinks = new Set();
    const elem = document.getElementById('graph');
    
        (async () => {
            //=================================================================================
            //Audio init
            //=================================================================================
            const { createFaustNode } = await import("./create-node.js");
            // Create audio context
            const AudioCtx = window.AudioContext || window.webkitAudioContext;
            const audioContext = new AudioCtx({ latencyHint: 0.00001 });
            audioContext.suspend();
            // Create Faust node for each Synth
            const { faustNode: additiveNode, dspMeta: { name } } = await createFaustNode(audioContext, "./audio/dsp-meta.json", "./audio/dsp-module.wasm","additive", FAUST_DSP_VOICES);
            const { faustNode: dropNode, dspMeta: { bubblename } } = await createFaustNode(audioContext, "./audio/drop-meta.json","./audio/drop-module.wasm",  "drop", FAUST_DSP_VOICES);
            const { faustNode: additivePlusNode, dspMeta: { additivename } } = await createFaustNode(audioContext, "./audio/additiveplus-dsp-meta.json", "./audio/additiveplus-dsp-module.wasm","additiveplus", FAUST_DSP_VOICES);
            
            if (!additiveNode) throw new Error("Faust DSP not compiled");
            // Connect the Faust node to the audio output
            dropNode.connect(audioContext.destination);
            additiveNode.connect(audioContext.destination);
            additivePlusNode.connect(audioContext.destination);
            if (additiveNode.getNumInputs() > 0) {
                const { connectToAudioInput } = await import("./create-node.js");
                await connectToAudioInput(audioContext, null, additiveNode, null);
            }
            //=================================================================================
            //Graph
            //=================================================================================
            const graph = new ForceGraph(elem)
                .backgroundColor('#101020')
                .nodeRelSize(6)
                // .nodeAutoColorBy('user')
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
                .onNodeDrag(node => {
                    // playfaust((node.x / 100) + (node.y / 10), degree[node.id] );
                })
                .onNodeDragEnd(node => {
                    // playfaust(0, degree[node.id]);
                })
                .onLinkHover(link => {
                    highlightNodes.clear();
                    highlightLinks.clear();

                    if (link) {
                    highlightLinks.add(link);
                    highlightNodes.add(link.source);
                    highlightNodes.add(link.target);
                    };
                })
                // .onNodeClick(node => shiftSelection(node, Graph));
                .onNodeHover(node => {
                if (!node){
                    // additiveNode.setParamValue('/additive/gate', 0);
                    return
                }
                if (!hoverOn){
                    // console.log(hoverOn)
                    return
                }
                // highlightNodes.clear();
                // highlightLinks.clear();
                // console.log(document.getElementById("mitch"));
                if (node) {
                    // console.log(node)
                    // highlightNodes.add(node);
                    // // console.log(node)
                    // if(!node.neighbors)
                    //     return
                    // node.neighbors.forEach(neighbor => highlightNodes.add(neighbor));
                    // node.links.forEach(link => highlightLinks.add(link));
                    
                    // console.log(node.neighbors.length)
                    // console.log(1250 - (degree[node.id] * 43.4/4))
                    console.log(220 + (degree[node.id] * 4));
                    playFaust(220 + (degree[node.id] * 4), 2, "bubbles", dropNode, audioContext);
                    }
                // hoverNode = node || null;
                });

            graph.nodeColor(node => {
                // Use the same coloring scheme you had initially
                // For example, if you used a color scale based on user property:
                return colorScale(node.user);
            });

            // let originalNodeColorFunction = graph.nodeAutoColorBy('user');
            // graph.onNodeClick(node => attractNeighbors(node, graph));
            // graph.onBackgroundClick(graph.nodeAutoColorBy('user'));
            // UPDATE LATER, it should also work if there's already a selectednode
            function setupNodeSelection(graph) {
                graph.onNodeClick((node, event) => {
                  if (shiftKeyPressed) {
                    shiftSelection(node, graph, degree, additivePlusNode, audioContext);
                    clearActiveAnimations();
                  } else {
                    selectNode(node, true, graph);
                    clearActiveAnimations();
                    if (spaceKeyPressed) {highlightNeighborsGradually(node, graph, degree, data, dropNode, audioContext)};
                  }
                });
            }
            setupNodeSelection(graph)
            // Create a color scale using d3-scale
            function createColorScale(graph) {
                // Get all unique user values
                const nodes = graph.graphData().nodes;
                const userValues = [...new Set(nodes.map(node => node.user))];
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
                graph.nodeColor(node => {
                    // Use the same coloring scheme you had initially
                    // For example, if you used a color scale based on user property:
                    return colorScale(node.user);
                  });
                // Reset link coloring and width
                // graph.linkColor(() => 'rgba(255,255,255,0.2)'); // Reset to default
                // graph.linkColor(link =>  '#'+(Math.random()*0xFFFFFF<<0).toString(16))
                graph.linkCurvature(0.2)
                graph.linkWidth(node => node.weight / 2.0)
                });
            }
            setupBackgroundClick(graph)
            // WASD - Interaction
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
                playFaust(220, degree[nextNode.id], "additiveplus", additivePlusNode, audioContext);
            }
            });

            // Track shift key state
            document.addEventListener('keydown', (event) => {
                if (event.key === 'Shift') {
                shiftKeyPressed = true;
                console.log("shiftKeyPressed");
                }
            });
            
            document.addEventListener('keyup', (event) => {
                if (event.key === 'Shift') {
                    shiftKeyPressed = false;
                    console.log("shiftKeyNotPressed");
                // Only clear selection when shift key is released if no animation is running
                if (!animationInProgress) {
                    selectedNodes = [];
                    updateNodeColors(graph);
                }
                }
            });

            // Track space bar state
            document.addEventListener('keydown', (event) => {
                if (event.key === ' ') {
                spaceKeyPressed = true;
                console.log("spaceKeyPressed");
                }
            });
            
            document.addEventListener('keyup', (event) => {
                if (event.key === ' ') {
                    spaceKeyPressed = false;
                    console.log("spaceKeyNotPressed");
                }
            });
            
        })();
});