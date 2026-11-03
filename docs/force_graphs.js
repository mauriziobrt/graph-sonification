import * as d3 from "https://cdn.jsdelivr.net/npm/d3@7/+esm";
import yaml from 'https://cdn.skypack.dev/yaml';
import { SuperSonic } from 'https://unpkg.com/supersonic-scsynth@latest/dist/supersonic.js';
//========================================================
// GLOBAL VARIABLES
//========================================================

// Launch SuperSonic
const supersonic = new SuperSonic({
    baseURL: 'https://unpkg.com/supersonic-scsynth@latest/dist/',
    coreBaseURL: 'https://unpkg.com/supersonic-scsynth-core@latest/',
    synthdefBaseURL: 'synthdefs/',
});

// Browsers start audio only after a click, tap or keypress
document.addEventListener("DOMContentLoaded", () => {
    document.querySelector('button').onclick = async () => {
        await supersonic.init();
        for (const name of ["hoverControlled", "wasdControlled", "bubble", "transition"]) {
            await supersonic.loadSynthDef(name);
            console.log(name);
        }        // supersonic.send('/s_new', 'sonic-pi-prophet', -1, 0, 0, 'note', 60);
    };
});

function lincurve(v, iMin, iMax, oMin, oMax, curve = -4) {
    if (v <= iMin) return oMin;
    if (v >= iMax) return oMax;
    const grow = Math.exp(curve), a = (oMax - oMin) / (1 - grow), b = oMin + a;
    return b - a * Math.pow(grow, (v - iMin) / (iMax - iMin));
}
const R2 = 2 ** (4 / 12);           // Scale.major.ratios[2]

function bank(n, freq, upper, N) {
    n = Math.max(1, Math.floor(n));
    const step = 2 * freq * R2, last = freq + (n - 1) * step, args = [];
    for (let i = 0; i < N; i++) {
        args.push("f" + i, lincurve(freq + i * step, freq, last, freq, upper));
        args.push("a" + i, i < n ? 1 : 0);
    }
    return args;
}

let graph;
let degree = {};
let dataNodes;
let dataLinks;
let colorScale;
// let node;

let dataTextSpec = "Bibliographic Coupling"; //e.g. Co-citations, Bibliographic Coupling
let dataText = document.getElementById("mySpec");
dataText.innerText = dataTextSpec;
let displayFeatures = false;

window.addEventListener('resize', () => {
    if (graph) {
        graph.width(window.innerWidth).height(window.innerHeight)
    }
})

// Open Access Colors
const OPENACCESS = {
    gold: '#fff260a7',
    green: '#cdfec5a6',
    diamond: '#1eeff6a1',
    closed: '#d4d4d466',
    hybrid: '#cf6acc7e'
};

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

    const info_text = document.getElementById("displayText");
    if (yml_cnt["display-text"]["display-features"]) {
        info_text.style = "z-index: 1";
    } else {
        info_text.style = "z-index: 0";
    }

    const tmp_text = document.getElementById("textControls");
    if (yml_cnt["display-text"]["display-navigation"]) {
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
    file: "select file",
    hoverOn: false,
    loadFile: function () { obj.file = selectFile().fileName },
    // labelDisplay: false,
    textDisplay: false,
    textHelp: false,
    bubbleAddress: "/bubblesv1",
    // oscPort: 57120,
    // reloadGraph: function() {updateGraphData(obj.file)}
}

var filedata = {
    "1-hover": ["./data/1-hover.json", "./data/1-config.yml"],
    "2-bubbles": ["./data/2-bubbles.json", "./data/2-config.yml"],
    "3-transition": ["./data/3-transition.json", "./data/3-config.yml"],
    "4-bib-coupling": ["./data/4-bib-coupling.json", "./data/4-config.yml"],
    "5-cit-coupling": ["./data/5-co-cit-coupling.json", "./data/5-config.yml"],
    // "7-test-db": ["./data/network_graph.json", "./data/6-config.yml"]
}

gui.add(obj, "hoverOn");
gui.add(obj, "file", ["1-hover", "2-bubbles", "3-transition", "4-bib-coupling", "5-cit-coupling"])
// gui.add(obj, "labelDisplay");
gui.add(obj, "textDisplay");
gui.add(obj, "textHelp");
gui.add(obj, "bubbleAddress", ["/control", "/bubblesv1", "/bubblesv2"]);

gui.onChange(event => {
    // console.log(event.property)-
    if (event.property == "hoverOn") {
        hoverOn = event.value;
        console.log('State hover: ', hoverOn);
    }
    if (event.property == "labelDsiplay") {
        labelDisplay = event.value;
        if (labelDisplay) graph.nodeLabel(node => `${node.user}: ${node.description}`)
        else graph.nodeLabel();
        console.log('State label: ', labelDisplay);
    }
    if (event.property == "textDisplay") {
        obj.textDisplay = event.value;
        const tmp_text = document.getElementById("displayText");
        if (obj.textDisplay) {
            tmp_text.style = "z-index: 1";
        } else {
            tmp_text.style = "z-index: 0";
        }
        console.log('State display: ', obj.textDisplay);
    }

    if (event.property == "textHelp") {
        obj.textHelp = event.value;
        const tmp_text = document.getElementById("textControls");
        if (obj.textHelp) {
            tmp_text.style = "z-index: 1";
        } else {
            tmp_text.style = "z-index: 0";
        }
        console.log('State display: ', obj.textHelp);
    }
    if (event.property == "") {

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
    if (event.property == "bubbleAddress") {
        bubbleAddress = event.value;
        console.log('State bubble: ', bubbleAddress);
    }
});

//====
// quick claude generated porting
//
const lin = (v, a, b, c, d) => c + (Math.min(Math.max(v, a), b) - a) / (b - a) * (d - c);

function hover({ cit, coupling, cluster, maxDegree, maxCit }) {
    const n = lincurve(cit, 0, maxCit, 1, 50);
    const vol = 10 ** (lin(cit, 0, maxCit, -5, 0) / 20);   // dbamp
    let freq, relTime;

    switch (cluster) {
        case 1:
            freq = lincurve(coupling, 0, maxDegree, 100, 1500);
            relTime = lincurve(coupling, 0, maxDegree, 100, 1300) / 300;
            break;
        case 2:
            freq = lincurve(coupling, 0, maxDegree, 1500, 100);
            relTime = lincurve(coupling, 0, maxDegree, 100, 1300) / 300;
            break;
        case 3:
            freq = lincurve(coupling, 0, maxDegree, 1300, 50);
            relTime = freq / 300;
            break;
        case 4:
            freq = lincurve(coupling, 0, maxDegree, 50, 1300);
            relTime = freq / 300;
            break;
        default: return;
    }
    console.log("Freq and reltime", freq, relTime);
    supersonic.send("/s_new", "hoverControlled", -1, 0, 0,
        "freq", freq, "relTime", relTime, "vol", vol,
        ...bank(n, freq, 10000, 50));
}

function wasd({ cit, coupling, maxCoupling, maxCit }) {
    const n = lincurve(cit, 0, maxCit, 1, 100);
    const freq = lincurve(coupling, 0, maxCoupling, 50, 1300);
    console.log("WASDING")
    supersonic.send("/s_new", "wasdControlled", -1, 0, 0,
        "freq", freq, "relTime", freq / 300, ...bank(n, freq, 15000, 100));
}

const bells = [
    [3958.2691669464, 2219.5205450058, 3720.8760738373, 3930.4407596588, 827.31196880341, 3670.5682277679, 550.56445598602, 3677.7821779251, 581.56654834747, 3224.8901605606, 2330.4237604141, 756.98308944702],
    [223.22008609772, 1996.9875097275, 3631.1988592148, 753.74145507812, 659.04550552368, 953.89244556427, 612.56682872772, 426.58507823944, 1644.7909116745, 875.82595348358, 1946.9505548477, 3229.9587249756],
    [3901.8504142761, 3278.7544727325, 3938.3745193481, 1065.1204586029, 3879.1404008865, 3816.3529872894, 2989.7552490234, 1730.3744077682, 678.00426483154, 2374.1246700287, 2525.9301900864, 3549.2574453354],
    [2657.4152469635, 912.29071617126, 1286.7574691772, 3869.4250106812, 1136.3956451416, 2689.750957489, 459.87751483917, 2751.2355566025, 3400.4847288132, 1524.5981216431, 2834.7212314606, 2828.8508653641],
    [1328.7076234818, 456.14535808563, 643.3787345886, 1934.7125053406, 568.1978225708, 1344.8754787445, 229.93875741958, 1375.6177783012, 1700.2423644066, 762.29906082155, 1417.3606157303, 1414.4254326821],
];

function bubble({ cit, coupling, cluster, maxCoupling, maxCit }) {
    const maxlength = 20;
    let div, rel;
    switch (cluster) {
        case 1: div = lincurve(coupling, 0, maxCoupling, 0.5, 5); rel = lincurve(coupling, 0, maxCoupling, 0, maxlength); break;
        case 2: div = lincurve(coupling, 0, maxCoupling, 5, 0.5); rel = lincurve(coupling, 0, maxCoupling, maxlength, 0); break;
        case 3: div = lincurve(coupling, 0, maxCoupling, 0.5, 5); rel = lincurve(coupling, 0, maxCoupling, 0, maxlength); break;
        case 4: div = lincurve(coupling, 0, maxCoupling, 0.5, 5); rel = lincurve(coupling, 0, maxCoupling, maxlength, 0); break;
        default: return;
    }
    const bell = bells[Math.floor(Math.random() * bells.length)];
    const amp = 10 ** (lin(cit, 0, maxCit, -12, -9) / 20);
    const args = [];
    for (let i = 0; i < 12; i++) {
        args.push("f" + i, bell[i] / div);
        args.push("r" + i, 0.1 + Math.random() * (cit / 10 - 0.1));
    }
    supersonic.send("/s_new", "bubble", -1, 0, 0,
        "atk", 0, "sus", 0, "rel", rel, "pan", Math.random() * 2 - 1, "amp", amp, ...args);
}

let trLast = 0, trNode = null;
function transition({ cit, coupling, cluster, maxCoupling, maxCit, time, stop }) {
    if (stop) {   // old code: msg[1] == 0
        if (trNode !== null) supersonic.send("/n_set", trNode, "fade", 10, "gate", 0);
        trNode = null; trLast = 0;
        return;
    }
    const myTime = time / 1000;   // old code: msg[5] / 1000
    let freq, n;
    switch (cluster) {
        case 1: freq = lincurve(coupling + 1, 0, maxCoupling, 800, 100); n = lincurve(cit, 0, maxCit, 1, 50) + 1; break;
        case 2: freq = lincurve(coupling + 1, 0, maxCoupling, 100, 800); n = lincurve(cit, 0, maxCit, 50, 1) + 1; break;
        case 3: freq = lincurve(coupling + 1, 0, maxCoupling, 100, 800); n = lincurve(maxCit - cit, 0, maxCit, 1, 50) + 1; break;
        case 4: freq = lincurve(coupling + 1, 0, maxCoupling, 800, 100); n = lincurve(maxCit - cit, 0, maxCit, 50, 1) + 1; break;
        default: return;
    }
    const fade = trLast === 0 ? myTime / 4 : trLast;
    trLast = myTime;
    if (trNode !== null) supersonic.send("/n_set", trNode, "fade", fade, "gate", 0);
    trNode = supersonic.nextNodeId();
    supersonic.send("/s_new", "transition", trNode, 0, 0,
        "fade", fade,
        "rate1", lincurve(cit, 0, maxCit, 0.001, 0.02),
        "rate2", lincurve(cit, 0, maxCit, 0.001, 0.03),
        ...bank(n, freq, 15000, 51));
}

//========================================================
// EVENT LISTENERS
//========================================================

// Initialize event listeners once when the page loads
function initializeEventListeners() {
    hotkeys('t', function (event, handler) {
        if (!selectedNode) return;
        switch (handler.key) {
            case 't':
                // hover example, cluster 1 (the other three clusters only change the freq/relTime lines)
                hover({
                    cit: selectedNode["citations"]/* citation value of the node */,
                    coupling: degree[selectedNode.id] /* coupling value */,
                    cluster: 1/* 1-4 */,
                    maxDegree: maxDegree/* max coupling in the graph */,
                    maxCit: maxCit/* max citation in the graph */
                });                // supersonic.send('/s_new', 'sonic-pi-prophet', -1, 0, 0, 'note', degree[selectedNode.id]);
                // sendOSCMessage(selectedNode, "/control", degree[selectedNode.id]);
                break;
        }
    });
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

    document.addEventListener('keydown', (event) => {
        if (!selectedNode) return;
        let direction;
        switch (event.key.toLowerCase()) {
            case 'w':
            case 'arrowup':
                direction = 'up';
                break;
            case 's':
            case 'arrowdown':
                direction = 'down';
                break;
            case 'a':
            case 'arrowleft':
                direction = 'left';
                break;
            case 'd':
            case 'arrowright':
                direction = 'right';
                break;
            default:
                return; // Not a WASD key
        }
        navigateNodes(direction);
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
}

// Call this once when your page loads
initializeEventListeners();

function navigateNodes(direction) {
    if (!selectedNode) return;
    if (!graph) return;
    const nextNode = findClosestNodeInDirection(selectedNode.id, direction, graph);
    if (nextNode) {
        // Select the new node WITHOUT centering the view
        // stopFaust();
        selectNode(nextNode, true, graph);
        // console.log(nextNode)
        document.getElementById("content").innerText = nextNode["description"];
        // document.getElementById("currentCluster").innerText = nextNode["cluster"];
        // playFaust(220, degree[nextNode.id], "additiveplus", additivePlusNode, audioContext);
        sendOSCMessage(nextNode, "/control", degree[nextNode.id])
        // console.log(degree)
    } else {
        console.error("No node in scope")
    }
}

window.navigateToDirection = function (direction) {
    navigateNodes(direction);
};

window.selectNodeById = function (nodeId) {
    if (!graph) return;
    const node = graph.graphData().nodes.find(n => n.id === nodeId);
    if (node) {
        selectNode(node, true, graph);
        document.getElementById("content").innerText = node["description"];
        document.getElementById("currentCluster").innerText = node["cluster"];
        document.getElementById("openaccess").innerText = node["openacces"];
        document.getElementById("citations").innerText = node["citations"];
        document.getElementById("year").innerText = node["year"];
        document.getElementById("co-citations").innerText = degree[node.id];
        sendOSCMessage(node, "/control", degree[node.id]);
    }
};

window.playSelectedNode = function () {
    if (!selectedNode) return;
    sendOSCMessage(selectedNode, "/control", degree[selectedNode.id])
}

function bubbleStart() {
    if (!graph) return;
    if (!selectedNode) return;
    clearActiveAnimations();
    highlightNeighborsGradually(selectedNode, graph, degree, dataNodes, dataLinks)
}

function getNodeById(nodeID) {
    return dataNodes.find(node => node.id === nodeID)
}

window.bubble = function () {
    bubbleStart();
}

window.transition = function (startID, endID) {
    const nodes = [getNodeById(startID), getNodeById(endID)];
    shiftKeyPressed = true;
    // getNodeById(startID).highlighted = true;
    // getNodeById(endID).highlighted = true;
    // graph.nodeColor(node => node.highlighted ? 'red' : 'gray');
    shiftSelection(getNodeById(startID), graph, degree);
    setTimeout(shiftSelection(getNodeById(endID), graph, degree), 5000);
    // connectSelectedNodes(nodes, graph, degree)
}

window.clearGraph = function () {
    // Reset selections
    selectedNodes = [];
    selectedNode = null;
    highlightedPath = [];
    clearActiveAnimations();
    clearTransitionAnimations();

    if (graph) {
        graph.nodeColor(node => {
            return colorScale(node.openacces);
        });

        graph.linkCurvature(0.2)
        graph.linkWidth(node => node.weight / 2.0)
    }
}

// Create a color scale using your custom colors
function createColorScale(graph) {
    const nodes = graph.graphData().nodes;
    const userValues = [...new Set(nodes.map(node => node.openacces))];

    // Map your custom colors to the domain values
    const colorScale = d3.scaleOrdinal()
        .domain(userValues)
        .range(userValues.map(color => OPENACCESS[color] || '#84848466')); // fallback to 'closed' color

    // const colorScale = d3.scaleOrdinal()
    //                 .domain(userValues)
    //                 .range(d3.schemePaired); // Use a predefined color scheme

    return colorScale;
}

function main(fileName) {
    fetchExternalData(fileName || obj.file).then(
        (data) => {
            data = data[0];
            degree = {};

            dataNodes = data.nodes;
            dataLinks = data.links;

            // Calculate node degrees
            data.links.forEach(link => {
                // console.log(link.source, link.target, link.weight);
                degree[link.source] = (degree[link.source] || 0) + 1;
                degree[link.target] = (degree[link.target] || 0) + 1;
            });

            const max = data.links.reduce((prev, current) => (prev && prev.weight > current.weight) ? prev : current)
            // console.log(max.weight)
            maxWeight = max.weight;

            // maxDegree = 
            const maxValue = Math.max(...Object.values(degree));
            maxDegree = maxValue

            // const maxCitations = Math.max(...Object.values(data["nodes"]["citations"]))
            const maxCitations = Math.max(...data.nodes.map(node => node.citations));
            console.log(maxCitations)
            // Find where the source is the starting point, get an array of that and then find where the target is the end point, there you have the weight

            const elem = document.getElementById('graph');

            // Initialize graph only once
            if (!graph) {
                graph = new ForceGraph(elem);
                // Set up your graph configuration here (one-time setup)
                graph
                    .backgroundColor('#101020')
                    .nodeRelSize(6)
                    // .nodeLabel(node => `${node.user}: ${node.description}`)
                    .linkCurvature(0.2)
                    .linkWidth(link => link.weight / 2.0)
                    .linkColor(() => linkStaticColor)
                    .nodeVal(node => degree[node.id] || 1) // Default to 1 if no links
                    .d3Force('charge', d3.forceManyBody().strength(node => -degree[node.id] * repulsionVal)) // Repulsion
                    .d3Force('collision', d3.forceCollide(node => degree[node.id] * 2)) // Prevent overlap
                    // .linkDirectionalParticles(2)
                    .graphData(data)
                    .autoPauseRedraw(false) // keep redrawing after engine has stopped
                    .onNodeHover(node => {
                        if (!node) {
                            return
                        }
                        if (node) {
                            if (hoverOn) {
                                selectNode(node, false, graph);
                                document.getElementById("content").innerText = node["description"];
                                document.getElementById("currentCluster").innerText = node["cluster"];
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
                    console.log(node);
                    document.getElementById("content").innerText = node["description"];
                    document.getElementById("openaccess").innerText = node["openacces"];
                    document.getElementById("citations").innerText = node["citations"];
                    document.getElementById("year").innerText = node["year"];
                    document.getElementById("co-citations").innerText = degree[node.id];
                    // document.getElementById("currentCluster").innerText = node["cluster"];

                    if (shiftKeyPressed) {
                        shiftSelection(node, graph, degree);
                        clearActiveAnimations();
                    } else {
                        selectNode(node, true, graph);
                        clearActiveAnimations();
                        if (spaceKeyPressed) { highlightNeighborsGradually(node, graph, degree, dataNodes, dataLinks); console.log("RHYTHM") }
                        else { sendOSCMessage(node, "/control", degree[node.id]) };
                    }
                });
            }
            setupNodeSelection(graph)

            colorScale = createColorScale(graph);

            graph.nodeColor(node => colorScale(node.openacces));

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
                    // graph.nodeColor(node => node["color"] ? 'red' : 'blue');

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

window.sendOSCMessage = (node, address, deg, weight) => {
    // console.log("I GOT CALLED")
    const base = { cit: node.citations, cluster: Number(node.cluster) || 1, maxCit };
    switch (address) {
        case "/control": hover({ ...base, coupling: deg, maxDegree }); break;
        case "/wasd": wasd({ ...base, coupling: deg, maxCoupling: maxDegree }); break;
        case "/bubblesv1":
        case "/bubblesv2": bubble({ ...base, coupling: weight ?? deg, maxCoupling: maxDegree }); break;
        case "/additive": transition({ ...base, coupling: deg, maxCoupling: maxDegree, time: currentWeightTime }); break;
    }
};
window.sendOSCStopMessage = (address) => {
    if (address === "/additive") transition({ stop: true });
};